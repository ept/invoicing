require 'invoicing_generator'

# Rails generator which creates the migration, models and a controller to support a basic ledger.
class InvoicingLedgerGenerator < Rails::Generator::NamedBase

  include InvoicingGenerator::NameTools
  include InvoicingGenerator::OptionTools

  default_options :description => true, :period => true, :uuid => true, :due_date => true, 
    :tax_point => true, :quantity => true, :creator => true, :timestamps => true, :debug => false

  attr_reader :name_details

  def initialize(runtime_args, runtime_options = {})
    super
    @name_details = {
      :controller  => extract_name_details(@name,                               :kind => :controller),
      :ledger_item => extract_name_details(args.shift || 'Billing::LedgerItem', :kind => :model),
      :line_item   => extract_name_details(args.shift || 'Billing::LineItem',   :kind => :model)
    }
    subclass_nesting = name_details[:ledger_item][:class_nesting]
    subclass_nesting << '::' unless subclass_nesting == ''
    name_details[:invoice]     = extract_name_details("#{subclass_nesting}Invoice",    :kind => :model)
    name_details[:credit_note] = extract_name_details("#{subclass_nesting}CreditNote", :kind => :model)
    name_details[:payment]     = extract_name_details("#{subclass_nesting}Payment",    :kind => :model)
    
    name_details[:controller ][:superclass] = 'ApplicationController'
    name_details[:ledger_item][:superclass] = 'ActiveRecord::Base'
    name_details[:invoice    ][:superclass] = name_details[:ledger_item][:class_name_base]
    name_details[:credit_note][:superclass] = name_details[:ledger_item][:class_name_base]
    name_details[:payment    ][:superclass] = name_details[:ledger_item][:class_name_base]
    name_details[:line_item  ][:superclass] = 'ActiveRecord::Base'
    
    dump_details if options[:debug]
  end
  
  def manifest
    record do |m|
      name_details.each_pair do |key, details|
        # Check for class naming collisions.
        m.class_collisions details[:class_path_array], details[:class_name_base]
        
        # Create directories
        m.directory File.dirname(details[:file_path_full])
        
        # Create classes
        m.nested_class_template "#{key}.rb", details
      end
      
      # Migration
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => 'create_invoicing_ledger'
      
      # Initializer
      m.file 'initializer.rb', 'config/initializers/invoicing.rb'
    end
  end

  protected
    def banner
      <<-EOS
Creates the model classes and migration for a ledger of accounting data.

USAGE: #{$0} invoicing_ledger ControllerName [LedgerItemsModelName] [LineItemsModelName] [options]

The recommended ControllerName is 'Billing'.
EOS
    end
    
    def with_or_without_options
      {
        :description => "create a description column for ledger and line items",
        :period => "create start_period/end_period columns for ledger items",
        :uuid => "create uuid columns for ledger and line items",
        :due_date => "create a due_date column for ledger items",
        :tax_point => "create a tax_point column for line items",
        :quantity => "create a quantity column for line items",
        :creator => "create a creator_id column for line items",
        :timestamps => "create created_at/updated_at columns"
      }
    end
end
