module Invoicing
  module Tax
    module AttrTaxable
      def attr_taxable(tax_logic, *method_names)
        method_names.each do |method_name|
          method_name = method_name.to_s
          generate_attr_taxable_getter(tax_logic, method_name)
          generate_attr_taxable_setter(tax_logic, method_name)
          generate_attr_taxable_error_getter(tax_logic, method_name)
          generate_attr_taxable_declarations(tax_logic, method_name)
        end
        
        generate_attr_taxable_before_validation(tax_logic)
        before_validation :convert_taxed_attributes
        
        other_methods = (tax_logic.respond_to?(:mixin_methods) ? tax_logic.mixin_methods : []) || []
        other_methods.each do |method_name|
          generate_attr_taxable_other_method(tax_logic, method_name.to_s)
        end
      end  

      def generate_attr_taxable_getter(tax_logic, method_name)
        define_method(method_name + "_taxed") do |*args|
          @taxed_attr_values ||= {}
          if @taxed_attr_values[method_name]
            @taxed_attr_values[method_name]
          else
            value = send(method_name)
            if value.nil?
              nil
            else
              value = value.to_f
              taxed = tax_logic.display_price_to_user({:model_object => self, :method => method_name, :value => value}, *args)
              ::Invoicing::Utils.round_to_currency_precision(taxed)
            end
          end
        end
      end
    
      def generate_attr_taxable_setter(tax_logic, method_name)
        define_method(method_name + "_taxed=") do |value|
          @taxed_attr_values ||= {}
          @taxed_attr_values[method_name] = value
        end
      end
    
      def generate_attr_taxable_error_getter(tax_logic, method_name)
        define_method(method_name + "_tax_rounding_error") do
          @taxed_attr_error ||= {}
          @taxed_attr_error[method_name] 
        end
      end
      
      def generate_attr_taxable_declarations(tax_logic, method_name)
        define_method(method_name + "_tax_info") do |*args|
          tax_logic.tax_info({:model_object => self, :method => method_name}, *args)
        end
        define_method(method_name + "_tax_details") do |*args|
          tax_logic.tax_info({:model_object => self, :method => method_name}, *args)
        end
      end
      
      def generate_attr_taxable_before_validation(tax_logic)
        define_method("convert_taxed_attributes") do
          @taxed_attr_values ||= {}
          @taxed_attr_error  ||= {}
          for method_name in @taxed_attr_values.keys
            value = @taxed_attr_values[method_name]
            
            if value.nil?
              send(method_name + "=", nil)
            else
              # FIXME check if value has a valid floating-point number format
              value = ::Invoicing::Utils.round_to_currency_precision(value.to_f)
              internal = tax_logic.input_price_from_user({:model_object => self, :method => method_name, :value => value})
              internal = ::Invoicing::Utils.round_to_currency_precision(internal)
              external = tax_logic.display_price_to_user({:model_object => self, :method => method_name, :value => internal})
              external = ::Invoicing::Utils.round_to_currency_precision(external)
              
              if external != value
                @taxed_attr_error[method_name] = (external > value) ? :high : :low
              end
            
              @taxed_attr_values[method_name] = external
              send(method_name + "=", internal)
            end
          end
        end
      end
      
      def generate_attr_taxable_other_method(tax_logic, method_name)
        define_method(method_name) do |*args|
          tax_logic.send(method_name, {:model_object => self}, *args)
        end
      end

      private :generate_attr_taxable_getter, :generate_attr_taxable_setter, :generate_attr_taxable_error_getter, \
        :generate_attr_taxable_declarations, :generate_attr_taxable_other_method
    end
  end
end
