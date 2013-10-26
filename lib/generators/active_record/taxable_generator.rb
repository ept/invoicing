require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class TaxableGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_migration_file
        migration_template "taxable_migration.rb", "db/migrate/invoicing_taxables.rb"
      end

      def copy_model
        template "taxable_model.rb", "app/models/tax_rate.rb"
      end
    end
  end
end
