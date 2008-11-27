module Ept
  module Invoicing
    module ActiveRecordMethods
      def attr_taxable(tax_logic, *attr_names)
        attr_names.each do |attribute_name|
          attribute_name = attribute_name.to_s
          generate_getter(tax_logic, attribute_name)
          generate_setter(tax_logic, attribute_name)
          generate_error_getter(tax_logic, attribute_name)
        end
        
        other_methods = [:short_tax_declaration, :long_tax_declaration] + tax_logic.mixin_methods
        other_methods.each do |method_name|
          generate_method(tax_logic, method_name.to_s)
        end
      end

      def generate_getter(tax_logic, attribute_name)
        define_method attribute_name + "_taxed" do |*args|
          @taxed_attr_values ||= {}
          if @taxed_attr_values[attribute_name]
            @taxed_attr_values[attribute_name]
          else
            value = send(attribute_name)
            if value.nil?
              nil
            else
              taxed = tax_logic.display_price_to_user({:model_object => self, :value => value}, *args)
              Ept::Invoicing::Utils.round_to_currency_precision(taxed)
            end
          end
        end
      end
    
      def generate_setter(tax_logic, attribute_name)
        define_method attribute_name + "_taxed=" do |value, *args|
          @taxed_attr_values ||= {}
          @taxed_attr_error  ||= {}
          @taxed_attr_values[attribute_name] = value
          
          if value.nil?
            send(attribute_name + "=", nil)
          else
            # FIXME check if value has a valid floating-point number format
            value = Ept::Invocing::Utils.round_to_currency_precision(value.to_f)
            internal = tax_logic.input_price_from_user({:model_object => self, :value => value}, *args)
            internal = Ept::Invoicing::Utils.round_to_currency_precision(internal)
            external = tax_logic.display_price_to_user({:model_object => self, :value => internal}, *args)
            external = Ept::Invoicing::Utils.round_to_currency_precision(external)
            
            if external != value
              @taxed_attr_error[fieldname] = (external > @taxed_attr_values[fieldname]) ? :high : :low
            end
          
            @taxed_attr_values[attribute_name] = external
            send(attribute_name + "=", internal)
          end
        end
      end
    
      def generate_error_getter(tax_logic, attribute_name)
        define_method attribute_name + "_tax_rounding_error" do
          @taxed_attr_error ||= {}
          @taxed_attr_error[attribute_name] 
        end
      end
      
      def generate_method(tax_logic, method_name)
        define_method method_name do |*args|
          tax_logic.send(method_name, {:model_object => self}, *args)
        end
      end
      
      private :generate_getter, :generate_setter, :generate_error_getter, :generate_method
    end
  end
end