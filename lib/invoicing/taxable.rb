module Invoicing
  #
  # taxed must be greater than or equal to untaxed.
  module Taxable
    module ActMethods
      def acts_as_taxable(*args)
        Invoicing::ClassInfo.acts_as(Invoicing::Taxable, self, args)
        
        attrs = taxable_class_info.new_args.map{|a| a.to_s }
        currency_attrs = attrs + attrs.map{|attr| "#{attr}_taxed"}
        currency_opts = taxable_class_info.all_options.update({:before_conversion => :convert_taxable_value})
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
      attr = attr.to_s.sub(/_taxed$/, '')
      tax_logic = taxable_class_info.all_options[:tax_logic]
      @taxed_or_untaxed ||= {}
      @taxed_attr_error ||= {}
      
      if @taxed_or_untaxed[attr] == :taxed
        value = read_attribute("#{attr}_taxed")
        value = tax_logic.remove_tax({:model_object => self, :attribute => attr, :value => value}) unless value.nil?
        write_attribute(attr, value)
        
        # Check whether a rounding error occurred. The call to write_attribute just now set
        # @taxed_or_untaxed[attr] = :untaxed so when we call send(attr), the 'else' branch below will
        # be executed, thus evaluating what happens if we re-apply tax to the tax-exclusive value.
        # Sorry to make it so confusing.
        new_value = send(attr)
        if value == new_value
          @taxed_attr_error[attr] = nil
        elsif value > new_value
          @taxed_attr_error[attr] = :low
        else
          @taxed_attr_error[attr] = :high
        end
      else
        value = read_attribute(attr)
        value = tax_logic.apply_tax({:model_object => self, :attribute => attr, :value => value}) unless value.nil?
        write_attribute("#{attr}_taxed", value)
        @taxed_attr_error[attr] = nil
      end
    end
    
    protected :write_attribute, :convert_taxable_value


    module ClassMethods #:nodoc:
      # Generate additional accessor method for attribute with getter +method_name+.
      def generate_attr_taxable_methods(method_name) #:nodoc:
        define_method("#{method_name}_tax_rounding_error") do
          convert_taxable_value(method_name)
          @taxed_attr_error[method_name] 
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
    end
    
  end
end