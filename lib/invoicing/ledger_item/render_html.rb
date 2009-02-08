module Invoicing
  module LedgerItem
    # Included into ActiveRecord model object when +acts_as_ledger_item+ is invoked.
    module RenderHTML
      # Shortcut for rendering an invoice or a credit note into a human-readable HTML format.
      # Can be called without any arguments, in which case a general-purpose representation is
      # produced. Can also be given options and a block for customising the output:
      #
      #   @invoice = Invoice.find(params[:id])
      #   @invoice.render_html :xhtml => false do |i|
      #     i.each_line_item do |line_item|
      #       ""
      #     end
      #   end
      def render_html(options={}, &block)
        output_builder = HTMLOutputBuilder.new(options)
        yield output_builder if block_given?
        output_builder.build(self)
      end
      
      
      class HTMLOutputBuilder #:nodoc:
        DEFAULTS = {
          :each_line_item => proc{|line_item|
            info = line_item.send(:line_item_class_info)
            "<tr><td>#{info.get(line_item, :description)}</td></tr>"
          }
        }
        
        def initialize(options)
          @custom = {}
        end
        
        def method_missing(method_id, *args, &block)
          method_id = method_id.to_sym
          unless DEFAULTS.include? method_id
            return super
          end
          if block_given? && args.empty?
            @custom[method_id] = proc &block
          elsif args.length == 1
            @custom[method_id] = proc{ args[0].to_s }
          else
            raise ArgumentError, "#{method_id} expects exactly one value or block argument"
          end
        end
        
        def invoke(fragment_id, *args)
          fragment = @custom[fragment_id] || DEFAULTS[fragment_id]
          fragment.call(*args)
        end
        
        def build(ledger_item)
          line_items = ledger_item.send(:ledger_item_class_info).get(ledger_item, :line_items)
          line_items.map{|i| invoke(:each_line_item, i) }.join
        end
      end
    end
  end
end
