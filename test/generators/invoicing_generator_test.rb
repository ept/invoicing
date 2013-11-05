# encoding: utf-8
require File.join(File.dirname(__FILE__), 'test_helper.rb')


class InvoicingGeneratorTest < Rails::Generators::TestCase
  tests Invoicing::Generators::ModelsGenerator
  destination File.expand_path("../../tmp", File.dirname(__FILE__))

  setup do
    prepare_destination
  end

  test "it should create migrations and models" do
    run_generator
  end
end
