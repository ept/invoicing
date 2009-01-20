module Invoicing
  # Utility module which can be included in <tt>ActiveRecord::Base</tt> subclasses which use
  # single table inheritance.
  module FindSubclasses
    
    def self.included(base) #:nodoc:
      base.send :extend, ClassMethods
    end

    module ClassMethods
      
      def inherited(subclass)
        remember_subclass subclass
      end
      
      def remember_subclass(subclass)
        @known_subclasses ||= [self]
        @known_subclasses << subclass unless @known_subclasses.include? subclass
        self.superclass.remember_subclass(subclass) if self.superclass.respond_to? :remember_subclass
      end
      
      def known_subclasses
        load_all_subclasses_found_in_database
        @known_subclasses ||= [self]
      end
      
      def load_all_subclasses_found_in_database
        query = "SELECT DISTINCT #{inheritance_column} FROM #{table_name}"
        for subclass_name in connection.select_all(query).map{|record| record[inheritance_column]}
          unless subclass_name.blank? # empty string or nil means base class
            begin
              compute_type(subclass_name)
            rescue NameError
              raise ActiveRecord::SubclassNotFound, # Error message borrowed from ActiveRecord::Base
                "The single-table inheritance mechanism failed to locate the subclass: '#{subclass_name}'. " +
                "This error is raised because the column '#{inheritance_column}' is reserved for storing the class in case of inheritance. " +
                "Please rename this column if you didn't intend it to be used for storing the inheritance class " +
                "or overwrite #{self.to_s}.inheritance_column to use another column for that information."
            end
          end
        end
      end
    end
  end
end