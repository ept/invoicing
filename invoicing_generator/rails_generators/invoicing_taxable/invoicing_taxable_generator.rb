class InvoicingTaxableGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Migration
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => 'create_invoicing_taxable'
      m.file 'tax_rate.rb', File.join('app/models', 'tax_rate.rb')
    end
  end

  protected
    def banner
      <<-EOS
Creates a ...

USAGE: #{$0} #{spec.name} name
EOS
    end
end