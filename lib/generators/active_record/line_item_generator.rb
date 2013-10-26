require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class LineItemGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_migrations
        migration_template "line_item_migration.rb", "db/migrate/invoicing_line_items.rb"
      end

      def copy_models
        template "line_item_model.rb", "app/models/invoicing_line_item.rb"
      end
    end
  end
end
