require 'rails/generators/active_record'

module Invoicing
  module Generators
    class LineItemGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_migrations
        migration_template "migration.rb", "db/migrate/invoicing_line_items.rb"
      end

      def copy_models
        template "model.rb", "app/models/invoicing_line_item.rb"
      end
    end
  end
end
