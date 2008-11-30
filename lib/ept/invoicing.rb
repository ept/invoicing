module Ept
  module Invoicing
    module ActiveRecordMethods
      def attr_taxable(tax_logic, *method_names)
        method_names.each do |method_name|
          method_name = method_name.to_s
          generate_getter(tax_logic, method_name)
          generate_setter(tax_logic, method_name)
          generate_error_getter(tax_logic, method_name)
          generate_declarations(tax_logic, method_name)
        end
        
        other_methods = (tax_logic.respond_to?(:mixin_methods) ? tax_logic.mixin_methods : []) || []
        other_methods.each do |method_name|
          generate_method(tax_logic, method_name.to_s)
        end
      end

      def generate_getter(tax_logic, method_name)
        define_method method_name + "_taxed" do |*args|
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
              ::Ept::Invoicing::Utils.round_to_currency_precision(taxed)
            end
          end
        end
      end
    
      def generate_setter(tax_logic, method_name)
        define_method method_name + "_taxed=" do |value, *args|
          @taxed_attr_values ||= {}
          @taxed_attr_error  ||= {}
          @taxed_attr_values[method_name] = value
          
          if value.nil?
            send(method_name + "=", nil)
          else
            # FIXME check if value has a valid floating-point number format
            value = ::Ept::Invoicing::Utils.round_to_currency_precision(value.to_f)
            internal = tax_logic.input_price_from_user({:model_object => self, :method => method_name, :value => value}, *args)
            internal = ::Ept::Invoicing::Utils.round_to_currency_precision(internal)
            external = tax_logic.display_price_to_user({:model_object => self, :method => method_name, :value => internal}, *args)
            external = ::Ept::Invoicing::Utils.round_to_currency_precision(external)
            
            if external != value
              @taxed_attr_error[method_name] = (external > @taxed_attr_values[method_name]) ? :high : :low
            end
          
            @taxed_attr_values[method_name] = external
            send(method_name + "=", internal)
          end
        end
      end
    
      def generate_error_getter(tax_logic, method_name)
        define_method method_name + "_tax_rounding_error" do
          @taxed_attr_error ||= {}
          @taxed_attr_error[method_name] 
        end
      end
      
      def generate_declarations(tax_logic, method_name)
        define_method method_name + "_tax_info" do |*args|
          tax_logic.tax_info({:model_object => self, :method => method_name}, *args)
        end
        define_method method_name + "_tax_details" do |*args|
          tax_logic.tax_info({:model_object => self, :method => method_name}, *args)
        end
      end
      
      def generate_method(tax_logic, method_name)
        define_method method_name do |*args|
          tax_logic.send(method_name, {:model_object => self}, *args)
        end
      end
      
      private :generate_getter, :generate_setter, :generate_error_getter, :generate_declarations, :generate_method
    end
  end
end