module Invoicing
  # If acts_as_tax_category is called, this module is mixed into the current class
  # as instance methods (using 'include').
  module TimeDependentMethods
    
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
  end
end
