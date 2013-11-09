module Invoicing
  module Generators
    class ModelsGenerator < Rails::Generators::Base
      desc "Generates models for ledger and taxable items"
      namespace "invoicing"

      def create_models
        invoke "invoicing:tax_rate",    ["tax_rate"]
        invoke "invoicing:ledger_item", ["ledger_item"]
        invoke "invoicing:line_item",   ["line_item"]
      end
    end
  end
end
