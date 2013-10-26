module Invoicing
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Generates models for ledger and taxable items"

      def create_records
        invoke "active_record:tax_rate",    ["tax_rate"]
        invoke "active_record:ledger_item", ["ledger_item"]
        invoke "active_record:line_item",   ["line_item"]
      end
    end
  end
end
