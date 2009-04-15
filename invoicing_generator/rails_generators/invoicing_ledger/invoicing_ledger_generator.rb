class InvoicingLedgerGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory 'some_folder'

      # Create stubs
      m.template "template.erb",  "some_file_after_erb.rb"
      # m.file     "file",         "some_file_copied"
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
