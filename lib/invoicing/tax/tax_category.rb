module Ept
  module Invoicing
    module Tax
      module TaxCategory
        # Replacements work as follows: one rate references the rate object which will replace it
        # in future. This means that even if we don't know future rates at a time when a rate
        # is assigned to an auction, we should always be able to convert it into the future
        # equivalent rate at a later point in time. It is possible for a rate to expire without
        # having a replacement, but this is not desirable, as we will not be able to calculate
        # any rate after a certain point in time. However, it is perfectly acceptable for several
        # old rates to convert into the same new rate. This should be used in cases where e.g.
        # percentage boundaries are shifted. The safe way of assigning these replacements would
        # be to over-estimate the cost, i.e. we assign a higher tax band as the new replacement
        # if there is any possibility that the item should be classed as that higher tax band,
        # and only assign a lower tax band as the replacement if any item in the old tax band
        # will definitely be within that lower tax band.
        #
        # valid_from: The moment from which the rate becomes valid (column type datetime)
        # valid_until: The moment in which the rate expires (not the last day on which it is valid!)
        # valid_until may be NULL (which means 'valid until further notice'), column type datetime
        def acts_as_tax_category(options={})
          include ::Ept::Invoicing::Tax::TaxCategoryMethods
          extend ::Ept::Invoicing::Tax::TaxCategoryClassMethods
          @tax_category_replaced_by = options[:replaced_by] || 'replaced_by_id'
          @tax_category_valid_from  = options[:valid_from ] || 'valid_from'
          @tax_category_valid_until = options[:valid_until] || 'valid_until'
          @tax_category_is_default  = options[:is_default ] || 'is_default'
          belongs_to :replaced_by, :class_name => class_name
          has_many :replaces, :class_name => class_name, :foreign_key => @tax_category_replaced_by
          
          # Get all those rates which may apply within a particular date range
          # (e.g. between now and one month from now).
          named_scope :valid_during_period, lambda{|not_before, not_after| {
            :conditions => [
              # Not yet expired at beginning of date range
              "(#{table_name}.#{@tax_category_valid_until} IS NULL OR #{table_name}.#{@tax_category_valid_until} > ?) AND " +
              
              # Comes into effect before end of date range
              "#{table_name}.#{@tax_category_valid_from} < ?",
              
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
            :joins => "LEFT JOIN #{table_name} predecessors ON predecessors.#{@tax_category_replaced_by} = #{table_name}.id",
            :group => "#{table_name}.id"
          }  
        end
      end
    end
  end
end