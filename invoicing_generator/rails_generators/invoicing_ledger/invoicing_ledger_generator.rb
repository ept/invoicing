require 'invoicing_generator/name_tools'

# Inject a custom command into the rails generator -- useful for rendering classes
# nested inside modules.
module Rails #:nodoc:
  module Generator
    module Commands
      class Create
        def nested_class_template(relative_source, relative_destination, template_options = {})
          # Render the relative_source template
          inside_template = render_file(source_path(relative_source), template_options) do |file|
            vars = template_options[:assigns] || {}
            b = binding
            vars.each { |k,v| eval "#{k} = vars[:#{k}] || vars['#{k}']", b }
            # Render the source file with the temporary binding
            ERB.new(file.read, nil, '-').result(b)
          end
          
          # Include the rendered string as the 'inside_template' variable when rendering the
          # nested_class.rb template
          options = template_options.dup
          options[:assigns] ||= {}
          options[:assigns]['inside_template'] = inside_template
          template('nested_class.rb', relative_destination, options)
        end
      end
    end
  end
end

# Rails generator which creates the migration, models and a controller to support a basic ledger.
class InvoicingLedgerGenerator < Rails::Generator::NamedBase
  
  include InvoicingGenerator::NameTools
  
  default_options :description => true, :period => true, :uuid => true, :due_date => true, 
    :tax_point => true, :quantity => true, :creator => true, :timestamps => true, :debug => false
    
  attr_reader :controller_details, :ledger_item_details, :line_item_details
    
  def initialize(runtime_args, runtime_options = {})
    super
    @controller_details = extract_name_details(@name, :kind => :controller)
    @ledger_item_details = extract_name_details(args.shift || 'billing/ledger_item', :kind => :model)
    @line_item_details = extract_name_details(args.shift || 'billing/line_items', :kind => :model)
    
    dump_details if options[:debug]
  end
  
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions controller_details[:class_path_array], controller_details[:class_name_base]
      m.class_collisions ledger_item_details[:class_path_array], ledger_item_details[:class_name_base]
      m.class_collisions ledger_item_details[:class_path_array], "Invoice"
      m.class_collisions ledger_item_details[:class_path_array], "CreditNote"
      m.class_collisions ledger_item_details[:class_path_array], "Payment"
      m.class_collisions line_item_details[:class_path_array], line_item_details[:class_name_base]
      
      # Directories
      m.directory File.join('app/controllers', controller_details[:class_path])
      m.directory File.join('app/models', ledger_item_details[:class_path])
      m.directory File.join('app/models', line_item_details[:class_path])

      # Migration
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => 'create_invoicing_ledger'

      # Model class stubs
      m.nested_class_template "ledger_item.rb", File.join('app/models', "#{ledger_item_details[:file_path_full]}.rb"),
        :assigns => { :details => ledger_item_details, :superclass => 'ActiveRecord::Base' }
      m.nested_class_template "invoice.rb", File.join('app/models', ledger_item_details[:class_path], "invoice.rb"),
        :assigns => { :details => ledger_item_details, :superclass => 'ActiveRecord::Base' }
      m.nested_class_template "credit_note.rb", File.join('app/models', ledger_item_details[:class_path], "credit_note.rb"),
        :assigns => { :details => ledger_item_details, :superclass => 'ActiveRecord::Base' }
      m.nested_class_template "payment.rb", File.join('app/models', ledger_item_details[:class_path], "payment.rb"),
        :assigns => { :details => ledger_item_details, :superclass => 'ActiveRecord::Base' }
      m.nested_class_template "line_item.rb", File.join('app/models', "#{line_item_details[:file_path_full]}.rb"),
        :assigns => { :details => line_item_details, :superclass => 'ActiveRecord::Base' }
      # m.file     "file",         "some_file_copied"
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
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      with_or_without_options.each_pair do |key, val|
        opt.on "--with-#{key}", val + (options[key] ? " (default)" : "") do
          options[key] = true
        end
        opt.on "--without-#{key}", "don't #{val}" + (options[key] ? " (default)" : "") do
          options[key] = false
        end
      end
      opt.on("--debug", "pring debugging output") { options[:debug] = true }
    end
    
    # Output debugging info
    def dump_details
      [:controller_details, :ledger_item_details, :line_item_details].each do |method|
        puts "%-40s %s" % ["#{method}:", self.send(method).inspect]
      end
    end
end
