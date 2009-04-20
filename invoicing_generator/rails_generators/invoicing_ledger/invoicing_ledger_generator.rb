require 'invoicing_generator'

# Rails generator which creates the migration, models and a controller to support a basic ledger.
class InvoicingLedgerGenerator < Rails::Generator::NamedBase

  include InvoicingGenerator::NameTools
  include InvoicingGenerator::OptionTools

  default_options :description => true, :period => true, :uuid => true, :due_date => true,
    :tax_point => true, :quantity => true, :creator => true, :identifier => false,
    :timestamps => true, :debug => false

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
        m.nested_class_template "#{key}.rb", details, :assigns => { :name_details => name_details }
      end
      
      # Migration
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => 'create_invoicing_ledger'
      
      # Static files
      m.directory 'config/initializers'
      m.file 'initializer.rb', 'config/initializers/invoicing.rb'
      view_directory = File.join('app/views', name_details[:controller][:underscore_base])
      m.directory view_directory
      m.file 'statement_view.html', File.join(view_directory, 'statement.html.erb')
      m.file 'ledger_view.html',    File.join(view_directory, 'ledger.html.erb')
      m.file 'stylesheet.css',      File.join('public/stylesheets', 'invoicing_ledger.css')
      
      # Routes
      ctrl = name_details[:controller][:underscore_base]
      m.add_routes(
        "map.ledger '#{ctrl}/:id/ledger', :controller => '#{ctrl}', :action => 'ledger'",
        "map.statement '#{ctrl}/:id/:other_id', :controller => '#{ctrl}', :action => 'statement', :id => /\\d+/, :other_id => nil",
        "map.document '#{ctrl}/document/:id', :controller => '#{ctrl}', :action => 'document'"
      )
    end
  end

  protected
    def banner
      <<-EOS
Creates the model classes and migration for a ledger of accounting data.

USAGE: #{$0} invoicing_ledger ControllerName [LedgerItemsModelName] [LineItemsModelName] [options]

The recommended ControllerName is 'Billing'.
The default model names are 'Billing::LedgerItem' and 'Billing::LineItem', respectively.
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
        :identifier => "create an identifier column for ledger items",
        :timestamps => "create created_at/updated_at columns"
      }
    end
    
    def add_options!(opt)
      super
      opt.separator ''
      opt.separator 'Optional configuration values:'
      opt.on "--currency=CODE", "set a default currency (3-letter code, e.g. USD or GBP)" do |currency|
        options[:currency] = currency.nil? ? nil : currency.upcase
      end
    end
end
