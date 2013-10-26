module Invoicing
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Generates models for ledger and taxable items"

      def create_migration
        invoke "active_record:taxable", ["test"]
      end
    end
  end
end
