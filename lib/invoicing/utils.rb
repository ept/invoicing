module Ept
  module Invoicing
    class Utils
      def self.round_to_currency_precision(value)
        return nil if value.nil?
        # FIXME make rounding precision configurable, depending on currency
        (value * 100.0).round / 100.0
      end
    end
  end
end