# Inject a custom command into the rails generator -- useful for rendering classes
# nested inside modules.
module Rails #:nodoc:
  module Generator
    module Commands
      class Create
        # A bit like the 'template' method, but wraps the rendered template output in a Ruby
        # class definition, potentially nested in one or more module definitions.
        # +name_details+ should be a hash in the form returned by
        # InvoicingGenerator::NameTools#extract_name_details, detailing information about
        # the class and to which file it should be written.
        def nested_class_template(relative_source, name_details, template_options = {})
          # Render the relative_source template
          inside_template = render_file(source_path(relative_source), template_options) do |file|
            vars = template_options[:assigns] || {}
            b = binding
            vars.each { |k,v| eval "#{k} = vars[:#{k}] || vars['#{k}']", b }
            # Render the source file with the temporary binding
            ERB.new(file.read, nil, '-').result(b)
          end
          
          # Prepare class and module definitions
          nesting = name_details[:class_nesting_array]
          index = -1
          header = nesting.map{|mod| index += 1; ('  ' * index) + "module #{mod}\n"}.join
          header << ('  ' * nesting.size) + "class #{name_details[:class_name_base]}"
          header << " < #{name_details[:superclass]}" unless [nil, ''].include? name_details[:superclass]
          header << "\n"
          footer = (0..nesting.size).to_a.reverse.map{|n| ('  ' * n) + "end\n"}.join
          indent = '  ' * (nesting.size + 1)
          
          # Write everything to file
          file(relative_source, name_details[:file_path_full], template_options) do
            header + inside_template.split("\n").map{|line| "#{indent}#{line}"}.join("\n") + "\n" + footer
          end
        end
      end
    end
  end
end
