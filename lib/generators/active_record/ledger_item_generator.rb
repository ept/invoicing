require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class LedgerItemGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_migrations
        migration_template "ledger_item_migration.rb", "db/migrate/invoicing_ledger_item.rb"
      end

      def copy_models
        template "ledger_item_model.rb", "app/models/invoicing_ledger_item.rb"
      end
    end
  end
end
