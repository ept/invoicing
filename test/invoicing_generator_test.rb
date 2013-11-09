require File.join(File.dirname(__FILE__), 'test_helper.rb')

require 'rails/generators/test_case'
require 'rails/generators/active_record'
require 'generators/invoicing/invoicing_generator'

class InvoicingGeneratorTest < Rails::Generators::TestCase
  TMP_PATH = File.expand_path("../tmp", File.dirname(__FILE__))

  tests Invoicing::Generators::ModelsGenerator
  destination TMP_PATH

  setup do
    prepare_destination
  end

  teardown do
    rmdir TMP_PATH
  end

  test "it should create models" do
    run_generator

    Dir.chdir(TMP_PATH) do
      # assert that models are created
      assert_file "app/models/invoicing_ledger_item.rb"
      assert_file "app/models/invoicing_line_item.rb"
      assert_file "app/models/invoicing_tax_rate.rb"
    end
  end

  test "it should create migrations" do
    ActiveRecord::Generators::Base.stub :next_migration_number, 1 do
      run_generator

      Dir.chdir(TMP_PATH) do
        # assert that models are created
        assert_file "db/migrate/1_invoicing_ledger_items.rb"
        assert_file "db/migrate/1_invoicing_line_items.rb"
        assert_file "db/migrate/1_invoicing_tax_rates.rb"
      end
    end
  end
end
