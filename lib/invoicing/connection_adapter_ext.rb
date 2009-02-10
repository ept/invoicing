module Invoicing
  # Extensions specific to certain database adapters. Currently only MySQL and PostgreSQL are
  # supported.
  class ConnectionAdapterExt
  
    # Creates a database-specific SQL fragment for evaluating a three-legged conditional function
    # in a query.
    def self.conditional_function(condition, value_if_true, value_if_false)
      case ActiveRecord::Base.connection.adapter_name
        when "MySQL"
          "IF(#{condition}, #{value_if_true}, #{value_if_false})"
        when "PostgreSQL"
          "CASE WHEN #{condition} THEN #{value_if_true} ELSE #{value_if_false} END"
        else
          raise "Database adapter #{ActiveRecord::Base.connection.adapter_name} not supported by invoicing gem"
      end
    end
  end
end
