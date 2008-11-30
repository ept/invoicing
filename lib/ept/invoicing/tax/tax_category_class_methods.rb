module Ept
  module Invoicing
    module Tax
      # If acts_as_tax_category is called, this module is mixed into the current class
      # as class methods (using 'extend').
      module TaxCategoryClassMethods
        
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
          can_be_selected(not_before, not_after).select{|rate| rate.send(@tax_category_is_default)}.first
        end
        
        # Returns the default rate which is in effect at the given date/time.
        def default_rate_at_date(reference_date)
          default_rate(reference_date, reference_date + 1.second)
        end          
      end
    end
  end
end