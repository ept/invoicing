# Tools for parsing command line options. Designed to be included into
# a subclass of Rails::Generator::NamedBase.
module InvoicingGenerator
  module OptionTools
    protected
    
    # Overrides Rails::Generator::Options#add_options!
    # Expects with_or_without_options to be defined in the importing class.
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Optional flags:'
      with_or_without_options.each_pair do |key, val|
        opt.on "--with-#{key}", val + (options[key] ? " (default)" : "") do
          options[key] = true
        end
        opt.on "--without-#{key}", "don't #{val}" + (options[key] ? " (default)" : "") do
          options[key] = false
        end
      end
      opt.on("--debug", "print debugging output") { options[:debug] = true }
    end
    
    # Output debugging info
    def dump_details
      name_details.each_pair do |key1, val1|
        puts "#{key1}:"
        val1.each_pair do |key2, val2|
          puts "    %-40s %s" % ["#{key2}:", val2.inspect]
        end
      end
    end
    
  end
end
