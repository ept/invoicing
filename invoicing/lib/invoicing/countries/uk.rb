module Invoicing
  module Countries
    module UK
      # Extremely simplistic implementation of UK VAT. This needs to be fixed.
      class VAT
        def apply_tax(params)
          params[:value] * BigDecimal('1.15')
        end
        
        def remove_tax(params)
          params[:value] / BigDecimal('1.15')
        end
        
        def tax_info(params)
          "(inc. VAT)"
        end
        
        def tax_details(params)
          "(including VAT at 15%)"
        end
      end
    end
  end
end
