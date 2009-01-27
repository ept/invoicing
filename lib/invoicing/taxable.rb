module Invoicing
  #
  # taxed must be greater than or equal to untaxed.
  module Taxable
    module ActMethods
      def acts_as_taxable(*args)
        Invoicing::ClassInfo.acts_as(Invoicing::Taxable, self, args)
        
        attrs = taxable_class_info.new_args.map{|a| a.to_s }
        currency_attrs = attrs + attrs.map{|attr| "#{attr}_taxed"}
        currency_opts = taxable_class_info.all_options.update({:conversion_input => :convert_taxable_value})
        acts_as_currency_value(currency_attrs, currency_opts)
        
        attrs.each {|attr| generate_attr_taxable_methods(attr) }
        
        if tax_logic = taxable_class_info.all_options[:tax_logic]
          other_methods = (tax_logic.respond_to?(:mixin_methods) ? tax_logic.mixin_methods : []) || []
          other_methods.each {|method_name| generate_attr_taxable_other_method(tax_logic, method_name.to_s) }
        else
          raise ArgumentError, 'You must specify a :tax_logic option for acts_as_taxable'
        end
      end
    end
    
    # If +write_attribute+ is called on a taxable attribute, we note whether the taxed or the untaxed
    # version contains the latest correct value. We don't do the conversion immediately in case the tax
    # logic requires a value of another attribute (which may be assigned later) to do its calculation.
    def write_attribute(attribute, value)
      attribute = attribute.to_s
      attr_regex = taxable_class_info.all_args.map{|a| a.to_s }.join('|')
      @taxed_or_untaxed ||= {}
      
      if attribute =~ /^(#{attr_regex})$/
        @taxed_or_untaxed[attribute] = :untaxed
      elsif attribute =~ /^(#{attr_regex})_taxed$/
        @taxed_or_untaxed[$1] = :taxed
      end
      
      super
    end
    
    # Called internally to convert between taxed and untaxed values. You shouldn't usually need to
    # call this method from elsewhere.
    def convert_taxable_value(attr)
      attr = attr.to_s
      attr_without_suffix = attr.sub(/(_taxed)$/, '')
      to_status = ($1 == '_taxed') ? :taxed : :untaxed

      @taxed_or_untaxed ||= {}
      from_status = @taxed_or_untaxed[attr_without_suffix] || :untaxed # taxed or untaxed most recently assigned?
      
      attr_to_read = attr_without_suffix
      attr_to_read += '_taxed' if from_status == :taxed
      
      if from_status == :taxed && to_status == :taxed
        # Special case: remove tax, apply rounding errors, apply tax again, apply rounding errors again.
        write_attribute(attr_without_suffix, send(attr_without_suffix))
        send(attr)
      else
        taxable_class_info.convert(self, attr_without_suffix, read_attribute(attr_to_read), from_status, to_status)
      end
    end
    
    protected :write_attribute, :convert_taxable_value


    module ClassMethods #:nodoc:
      # Generate additional accessor method for attribute with getter +method_name+.
      def generate_attr_taxable_methods(method_name) #:nodoc:
        
        define_method("#{method_name}_tax_rounding_error") do
          original_value = read_attribute("#{method_name}_taxed")
          return nil if original_value.nil? # Can only have a rounding error if the taxed attr was assigned
          
          original_value = BigDecimal.new(original_value.to_s)
          converted_value = send("#{method_name}_taxed")
          
          if original_value == converted_value
            nil
          elsif original_value > converted_value
            :low
          else
            :high
          end        
        end

        define_method("#{method_name}_tax_info") do |*args|
          tax_logic = taxable_class_info.all_options[:tax_logic]
          tax_logic.tax_info({:model_object => self, :attribute => method_name}, *args)
        end

        define_method("#{method_name}_tax_details") do |*args|
          tax_logic = taxable_class_info.all_options[:tax_logic]
          tax_logic.tax_info({:model_object => self, :attribute => method_name}, *args)
        end
      end
      
      # Generate a proxy method called +method_name+ which is forwarded to the +tax_logic+ object.
      def generate_attr_taxable_other_method(method_name) #:nodoc:
        define_method(method_name) do |*args|
          tax_logic = taxable_class_info.all_options[:tax_logic]
          tax_logic.send(method_name, {:model_object => self}, *args)
        end
      end

      private :generate_attr_taxable_methods, :generate_attr_taxable_other_method
    end # module ClassMethods
    
    
    class ClassInfo < Invoicing::ClassInfo::Base #:nodoc:
      # Performs the conversion between taxed and untaxed values. Arguments +from_status+ and
      # +to_status+ must each be either <tt>:taxed</tt> or <tt>:untaxed</tt>.
      def convert(object, attr_without_suffix, value, from_status, to_status)
        return nil if value.nil?
        value = BigDecimal.new(value.to_s)
        return value if from_status == to_status
        
        if to_status == :taxed
          all_options[:tax_logic].apply_tax({:model_object => object, :attribute => attr_without_suffix, :value => value})
        else
          all_options[:tax_logic].remove_tax({:model_object => object, :attribute => attr_without_suffix, :value => value})
        end
      end
    end
    
  end
end