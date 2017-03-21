require 'rails/generators/active_record'

module Invoicing
  module Generators
    class TaxRateGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_migration_file
        migration_template "migration.rb", "db/migrate/invoicing_tax_rates.rb"
      end

      def copy_model
        template "model.rb", "app/models/invoicing_tax_rate.rb"
      end
    end
  end
end
