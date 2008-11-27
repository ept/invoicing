module Ept
  module Invoicing
    module Countries
      module UK
        
        class VAT
          def self.rates
            { '1991-04-01' => 0.175, '2008-12-01' => 0.15, '2010-01-01' => 0.175 }
          end
          
          def self.factor_at_date(reference_date)
            unless reference_date.kind_of? Date
              reference_date = reference_date.respond_to?(:to_date) ? reference_date.to_date : Date.parse(reference_date)
            end
            most_recent_str = nil
            most_recent_date = nil
            for date_str in rates.keys
              date = Date.parse(date_str)
              if (most_recent_date.nil? || (date > most_recent_date)) && (date <= reference_date)
                most_recent_date = date
                most_recent_str  = date_str
              end
            end
            rates[most_recent_str]
          end
          
          def self.factor_today
            self.factor_at_date(Date.today)
          end
          
          def self.percentage_at_date(reference_date)
            100.0*factor_at_date(reference_date)
          end
          
          def self.percentage_today
            self.percentage_at_date(Date.today)
          end
        end
        
      end
    end
  end
end