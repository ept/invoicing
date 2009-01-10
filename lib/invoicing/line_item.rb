module Invoicing
  module LineItem
    # Line item methods:
    #  
    # ledger_item         # Invoice or credit note
    # type                # For single table inheritance
    # net_amount          # Not including taxes
    # tax_amount
    # note/description
    #  
    # optional line item methods:
    #  
    # uuid
    # quantity            # Numeric
    # tax_point           # Datetime
    # tax_rate_id         # Reference to acts_as_tax_rate
    # price_id            # Reference to acts_as_price
    # created_at
    # updated_at
    # creator_id          # Reference to user whose action caused this line item to be created
    class Base < ::ActiveRecord::Base
      
    end
  end
end