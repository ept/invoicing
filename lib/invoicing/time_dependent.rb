module Invoicing
  # == Time-dependent value objects
  #
  # This module implements the notion of a value (or a set of values) which may change at
  # certain points in time, and for which it is important to have a full history of values
  # for every point in time. It is used in the invoicing framework as basis for tax rates,
  # prices, commissions etc.
  #
  # === Background
  #
  # To illustrate the need for this tool, consider for example the case of a tax rate. Say
  # the rate is currently 10%, and in a naive implementation you simply store the value
  # <tt>0.1</tt> in a constant. Whenever you need to calculate tax on a price, you multiply
  # the price with the constant, and store the result together with the price in the database.
  # Then, one day the government decides to increase the tax rate to 12%. On the day the
  # change takes effect, you change the value of the constant to <tt>0.12</tt>.
  #
  # This naive implementation has a number of problems, which are addressed by this module:
  # * With a constant, you have no way of informing users what a price will be after an
  #   upcoming tax change. Using +TimeDependent+ allows you to query the value at any date
  #   in the past or future, and show it to users as appropriate. You also gain the ability
  #   to process back-dated or future-dated transactions if this should be necessary.
  # * With a constant, you have no explicit information in your database informing you which
  #   rate was applied for a particular tax calculation. You may be able to infer the rate
  #   from the prices you store, but this may not be enough in cases where there is additional
  #   metadata attached to tax rates (e.g. if there are different tax rates for different
  #   types of product). With +TimeDependent+ you can have an explicit reference to the tax
  #   object which formed the basis of a calculation, giving you a much better audit trail.
  # * If there are different tax categories (e.g. a reduced rate for products of type A, and
  #   a higher rate for type B), the government may not only change the rates themselves, but
  #   also decide to reclassify product X as type B rather than type A. In any case you will
  #   need to store the type of each of your products; however, +TimeDependent+ tries to
  #   minimize the amount of reclassifying you need to do, should it become necessary.
  #
  # == Data Structure
  #
  # +TimeDependent+ objects are special +ActiveRecord::Base+ objects. One database table is used,
  # and each row in that table represents the value (e.g. the tax rate or the price) during
  # a particular period of time. If there are multiple different values at the same time (e.g.
  # a reduced tax rate and a higher rate), each of these is also represented as a separate
  # row. That way you can refer to a +TimeDependent+ object from another model object (such as
  # storing the tax category for a product), and refer simultaneously to the type of tax
  # applicable for this product and the period for which this classification is valid.
  #
  # If a rate change is announced, it <b>important that the actual values in the table
  # are not changed</b> in order to preserve historical information. Instead, add another
  # row (or several rows), taking effect at the appropriate date. However, it is usually
  # not necessary to update your other model objects to refer to these new rows; instead,
  # each +TimeDependent+ object which expires has a reference to the new +TimeDependent+
  # objects which replaces it. +TimeDependent+ provides methods for finding the current (or
  # future) rate by following this chain of replacements.
  #
  # === Example
  #
  # To illustrate, take as example the rate of VAT (Value Added Tax) in the United Kingdom.
  # The main tax rate was at 17.5% until 1 December 2008, when it was changed to 15%.
  # On 1 January 2010 it is due to be changed back to 17.5%. At the same time, there are a
  # reduced rates of 5% and 0% on certain goods; while the main rate was changed, the
  # reduced rates stayed unchanged.
  #
  # The table of +TimeDependent+ records will look something like this:
  #
  #   +----+-------+---------------+------------+---------------------+---------------------+----------------+
  #   | id | value | description   | is_default | valid_from          | valid_until         | replaced_by_id |
  #   +----+-------+---------------+------------+---------------------+---------------------+----------------+
  #   |  1 | 0.175 | Standard rate |          1 | 1991-04-01 00:00:00 | 2008-12-01 00:00:00 |              4 | 
  #   |  2 |  0.05 | Reduced rate  |          0 | 1991-04-01 00:00:00 | NULL                |           NULL |
  #   |  3 |   0.0 | Zero rate     |          0 | 1991-04-01 00:00:00 | NULL                |           NULL |
  #   |  4 |  0.15 | Standard rate |          1 | 2008-12-01 00:00:00 | 2010-01-01 00:00:00 |              5 | 
  #   |  5 | 0.175 | Standard rate |          1 | 2010-01-01 00:00:00 | NULL                |           NULL | 
  #   +----+-------+---------------+------------+---------------------+---------------------+----------------+
  #
  # Graphically, this may be illustrated as:
  #
  #             1991-04-01             2008-12-01             2010-01-01
  #                      :                      :                      :
  #   Standard rate: 17.5% -----------------> 15% ---------------> 17.5% ----------------->
  #                      :                      :                      :
  #   Zero rate:        0% --------------------------------------------------------------->
  #                      :                      :                      :
  #   Reduced rate:     5% --------------------------------------------------------------->
  #
  # It is a deliberate choice that a +TimeDependent+ object references its successor, and not
  # its predecessor. This is so that you can classify your items based on the current
  # classification, and be sure that if the current rate expires there is an unambiguous
  # replacement for it. On the other hand, it is usually not important to know what the rate
  # for a particular item would have been at some point in the past.
  #
  # Now consider a slightly more complicated (fictional) example, in which a UK court rules
  # that teacakes have been incorrectly classified for VAT purposes, namely that they should
  # have been zero-rated while actually they had been standard-rated. The court also decides
  # that all sales of teacakes before 1 Dec 2008 should maintain their old standard-rated status,
  # while sales from 1 Dec 2008 onwards should be zero-rated.
  #
  # Assume you have an online shop in which you sell teacakes and other goods (both standard-rated
  # and zero-rated). You can handle this reclassification (in addition to the standard VAT rate
  # change above) as follows:
  #
  #             1991-04-01             2008-12-01             2010-01-01
  #                      :                      :                      :
  #   Standard rate: 17.5% -----------------> 15% ---------------> 17.5% ----------------->
  #                      :                      :                      :
  #   Teacakes:      17.5% ------------.        :                      :
  #                      :              \_      :                      :
  #   Zero rate:        0% ---------------+->  0% ---------------------------------------->
  #                      :                      :                      :
  #   Reduced rate:     5% --------------------------------------------------------------->
  #
  # Then you just need to update the teacake products in your database, which previously referred
  # to the 17.5% object valid from 1991-04-01, to refer to the special teacake rate. None of the
  # other products need to be modified. This way, the teacakes will automatically switch to the 0%
  # rate on 2008-12-01. If you add any new teacake products to the database after December 2008, you
  # can refer either to the teacake rate or to the new 0% rate which takes effect on 2008-12-01;
  # it won't make any difference.
  #
  # == Usage notes
  #
  # This implementation is designed for tables with a small number of rows (no more than a few
  # dozen) and very infrequent changes. To reduce database load, it caches model objects very
  # aggressively; <b>you will need to restart your Ruby interpreter after making a change to
  # the data</b> as the cache is not cleared between requests. This is ok because you shouldn't
  # be lightheartedly modifying +TimeDependent+ data anyway; a database migration is probably
  # the best way of introducing a rate change (that way you can also check it all looks correct
  # on your staging server before making the rate change public).
  #
  # A model object using +TimeDependent+ must inherit from +ActiveRecord::Base+ and must have
  # at least the following columns (although columns may have different names, if declared to
  # +acts_as_time_dependent+):
  # * <tt>id</tt> -- An integer primary key
  # * <tt>valid_from</tt> -- A column of type <tt>datetime</tt>, which must not be <tt>NULL</tt>.
  #   It contains the moment at which the rate takes effect. The oldest <tt>valid_from</tt> dates
  #   in the table should be in the past by a safe margin.
  # * <tt>valid_until</tt> -- A column of type <tt>datetime</tt>, which contains the moment from
  #   which the rate is no longer valid. It may be <tt>NULL</tt>, in which case the the rate is
  #   taken to be "valid until further notice". If it is not <tt>NULL</tt>, it must contain a
  #   date later than <tt>valid_from</tt>, and the <tt>replaced_by_id</tt> column must contain
  #   the ID of a replacement object in this same table. The <tt>valid_from</tt> value of that
  #   replacement object must be equal to the <tt>valid_until</tt> value of this object.
  # * <tt>replaced_by_id</tt> -- An integer, foreign key reference to the <tt>id</tt> column in
  #   this same table. It is used only if <tt>valid_until</tt> is non-<tt>NULL</tt>.
  #
  # Optionally, the table may have further columns:
  # * <tt>value</tt> -- The actual (usually numeric) value for which we're going to all this
  #   effort, e.g. a tax rate percentage or a price in some currency unit.
  # * <tt>is_default</tt> -- A boolean column indicating whether or not this object should be
  #   considered a default during its period of validity. This may be useful if there are several
  #   different rates in effect at the same time (such as standard, reduced and zero rate in the
  #   example above). If this column is used, there should be exactly one default rate at any
  #   given point in time, otherwise results are undefined.
  #
  # Apart from these requirements, a +TimeDependent+ object is a normal model object, and you may
  # give it whatever extra metadata you want, and make references to it from any other model object.
  module TimeDependent

    def self.included(base)
      base.send :extend, ClassMethods
      #base.alias_method_chain :find, :aggressive_caching
    end

    
    module ClassMethods
      # Get all those rates which may apply within a particular date/time range
      # (e.g. between now and one month from now).
      # If rates are changing during this time interval, and one rate is replacing
      # another, then only the earliest element of each replacement chain is returned
      # (because we can convert from an earlier rate to a later one, but not necessarily
      # in reverse).
      def can_be_selected(not_before, not_after)
        valid_rates = valid_during_period(not_before, not_after).with_predecessors
        ids = valid_rates.map{|rate| rate.id}
        valid_rates.select{|rate| rate.predecessors.empty? || (ids & rate.predecessors).empty?}
      end
      
      # Returns the default rate from within the set of rates returned by 'can_be_selected',
      # or nil if none is found.
      def default_rate(not_before, not_after)
        can_be_selected(not_before, not_after).select{|rate| rate.send(:is_default)}.first
      end
      
      # Returns the default rate which is in effect at the given date/time.
      def default_rate_at_date(reference_date)
        default_rate(reference_date, reference_date + 1.second)
      end          
    end # module ClassMethods
    
    
    def find_with_aggressive_caching(*args)
      puts "find_with_aggressive_caching"
      find_without_aggressive_caching(*args)
#      expects_array = ids.first.kind_of?(Array)
#      return ids.first if expects_array && ids.first.empty?
#
#      ids = ids.flatten.compact.uniq
#
#      case ids.size
#        when 0
#          raise RecordNotFound, "Couldn't find #{name} without an ID"
#        when 1
#          result = find_one(ids.first, options)
#          expects_array ? [ result ] : result
#        else
#          find_some(ids, options)
#      end
    end


    # Roughly the same as the 'replaces' relation except that:
    # - this function returns an array of IDs, while 'replaces' returns an array of objects
    # - this function can return without performing an SQL query if the query was performed
    #   using the 'with_predecessors' scope.
    def predecessors
      if respond_to? :predecessor_ids
        # Called with 'with_predecessors' scope :-)
        predecessor_ids.nil? ? [] : predecessor_ids.split(',').map{|id| id.to_i}
      else
        # Not called with scope -- need to make a query :-(
        replaces.map{|rate| rate.id}
      end
    end
    
    # If this rate is still valid at the given date/time, this method just returns self.
    # If this rate is no longer valid at the given date/time, the rate object which has been
    # marked as this rate's replacement for the given point in time is returned.
    # If this rate has expired and there is no valid replacement, nil is returned.
    def rate_at_date date
      if valid_until.nil? || (valid_until > date)
        self
      elsif replaced_by.nil?
        nil
      else
        replaced_by.rate_at_date date
      end
    end
  
    # Returns self, or if this rate has expired, the replacement which is valid at this moment.
    # If there is no valid replacement, nil is returned.
    def rate_today
      rate_at_date Time.now
    end
    
    # Examines the replacement chain from this rate object into the future. If the rate
    # stays the same throughout the duration starting at from_date and ending at to_date,
    # an empty array is returned; otherwise an array of Time objects is returned, each
    # Time object indicating the date and time at which a rate change will occur.
    def changes_during_period(from_time, to_time)
      changes = []
      rate_object = self
      while !rate_object.nil? && !rate_object.valid_until.nil? && (rate_object.valid_until <= to_time)
        changes << rate_object.valid_until if rate_object.valid_until > from_time
        rate_object = rate_object.replaced_by
      end
      changes
    end
    
  end # module TimeDependent
  
  class TimeDependentClassInfo
    def initialize(model_class, options={})
      @model_class = model_class
      @methods = {}
      [:id, :valid_from, :valid_until, :replaced_by_id, :value, :is_default].each do |name|
        @methods[name] = (options[name] || name).to_s
      end
    end
  end

  module TimeDependentActMethods
    # Identifies the current model object as a +TimeDependent+ object, and creates all the
    # necessary methods.
    #
    # Accepts options in a hash, all of which are optional:
    # * <tt>id</tt> -- Alternative name for the <tt>id</tt> column
    # * <tt>valid_from</tt> -- Alternative name for the <tt>valid_from</tt> column
    # * <tt>valid_until</tt> -- Alternative name for the <tt>valid_until</tt> column
    # * <tt>replaced_by_id</tt> -- Alternative name for the <tt>replaced_by_id</tt> column
    # * <tt>value</tt> -- Alternative name for the <tt>value</tt> column
    # * <tt>is_default</tt> -- Alternative name for the <tt>is_default</tt> column
    #
    # Example:
    #
    #   class CommissionRate < ActiveRecord::Base
    #     acts_as_time_dependent :value => :rate
    #     belongs_to :referral_program
    #     named_scope :for_referral_program, lambda { |p| { :conditions => { :referral_program_id => p.id } } }
    #   end
    #   
    #   reseller_program = ReferralProgram.find(1)
    #   commission = CommissionRate.for_referral_program(reseller_program).current_default_object
    #   puts "Earn #{commission.rate} per cent commission as a reseller..."
    #   
    #   for change_date in commission.changes_during_period(Time.now, 1.year.from_now)
    #     new_rate = commission.rate_at_date(change_date)
    #     puts "Changing to #{new_rate} per cent on #{change_date.strftime('%d %b %Y')}!"
    #   end
    #
    def acts_as_time_dependent(options={})
      return if @time_dependent_class_info
      @time_dependent_class_info = ::Invoicing::TimeDependentClassInfo.new(self, options)
      
      include ::Invoicing::TimeDependent
      
      belongs_to :replaced_by, :class_name => class_name
      has_many :replaces, :class_name => class_name, :foreign_key => 'replaced_by_id'
      
      # Get all those rates which may apply within a particular date range
      # (e.g. between now and one month from now).
      named_scope :valid_during_period, lambda{|not_before, not_after| {
        :conditions => [
          # Not yet expired at beginning of date range
          "(#{table_name}.valid_until IS NULL OR #{table_name}.valid_until > ?) AND " +
          
          # Comes into effect before end of date range
          "#{table_name}.valid_from < ?",
          
          not_before, not_after
        ]
      }}
      
      # Adds an aggregated column 'predecessor_ids' to a query: for each rate object, this column
      # contains a comma-separated list of rate object IDs which refer to this object through the
      # replaced_by relation (i.e. the rate's predecessors). This is equivalent to invoking
      # rate.replaces.join(',') for each object, but results in only one SQL query rather than
      # many. For objects with no predecessors, the additional column is nil.
      # This named scope may only work in MySQL.
      named_scope :with_predecessors, {
        :select => "#{table_name}.*, GROUP_CONCAT(predecessors.id SEPARATOR ',') AS predecessor_ids",
        :joins => "LEFT JOIN #{table_name} predecessors ON predecessors.replaced_by_id = #{table_name}.id",
        :group => "#{table_name}.id"
      }  
    end # acts_as_time_dependent
    
    def acts_as_tax_category(options={})
      acts_as_time_dependent(options)
    end
  end # module TimeDependentActMethods
end
