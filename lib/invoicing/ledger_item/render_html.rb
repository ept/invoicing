require 'builder'

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
        output_builder = HTMLOutputBuilder.new(self, options)
        yield output_builder if block_given?
        output_builder.build
      end
      
      
      class HTMLOutputBuilder #:nodoc:
      
        HTML_ESCAPE = { '&' => '&amp;', '>' => '&gt;', '<' => '&lt;', '"' => '&quot;' }
        
        attr_reader :ledger_item, :options, :custom_fragments
        
        def initialize(ledger_item, options)
          @ledger_item = ledger_item
          @options = options
          @custom_fragments = {}
        end

        def h(s)
          s.to_s.gsub(/[#{HTML_ESCAPE.keys.join}]/) { |char| HTML_ESCAPE[char] }
        end
        
        # foo { block }   => call block when invoking fragment foo
        # foo "string"    => return string when invoking fragment foo
        # invoke_foo      => invoke fragment foo; if none set, delegate to default_foo
        def method_missing(method_id, *args, &block)
          method_id = method_id.to_sym
          if method_id.to_s =~ /^invoke_(.*)$/
            method_id = $1.to_sym
            if custom_fragments[method_id]
              return custom_fragments[method_id].call(*args, &block)
            else
              return send("default_#{method_id}", *args, &block)
            end
          end
          
          return super unless respond_to? "default_#{method_id}"
          
          if block_given? && args.empty?
            custom_fragments[method_id] = proc &block
          elsif args.length == 1
            custom_fragments[method_id] = proc{ args[0].to_s }
          else
            raise ArgumentError, "#{method_id} expects exactly one value or block argument"
          end
        end
        
        # Returns the value of a (potentially renamed) method on the ledger item
        def get(method_id)
          ledger_item.send(:ledger_item_class_info).get(ledger_item, method_id)
        end
        
        # String for one level of indentation
        def indent
          '    '
        end
        
        # This is quite meta. :)
        #
        #   params_hash(:sender_label, :sender_tax_number => :tax_number_label)
        #     # => {:sender_label => invoke_sender_label,
        #     #     :sender_tax_number => invoke_sender_tax_number(params_hash(:tax_number_label))}
        def params_hash(*param_names)
          result = {}
          param_names.flatten!
          options = param_names.extract_options!
          
          param_names.each{|param| result[param.to_sym] = send("invoke_#{param}") }
          
          options.each_pair do |key, value|
            result[key.to_sym] = send("invoke_#{key}", params_hash(value))
          end
          
          result
        end

        # Renders an invoice or credit note to HTML
        def build
          invoke_page_layout(params_hash(
            :title_tag => :title,
            :addresses_table => [:sender_label, :recipient_label, :sender_address, :recipient_address,
              {:sender_tax_number    => :tax_number_label,
               :recipient_tax_number => :tax_number_label}
            ],
            :metadata_table => {
              :identifier   =>  :identifier_label,
              :issue_date   => [:date_format, :issue_date_label],
              :period_start => [:date_format, :period_start_label],
              :period_end   => [:date_format, :period_end_label],
              :due_date     => [:date_format, :due_date_label]
            }
          ))
        end
        
        def default_date_format
          "%Y-%m-%d"
        end
        
        def default_title
          (get(:total_amount) < BigDecimal('0')) ? 'Credit Note' : 'Invoice'
        end
        
        def default_title_tag(params)
          "<h1 class=\"invoice\">#{params[:title]}</h1>\n"
        end
        
        def default_recipient_label
          "Recipient"
        end
        
        def default_sender_label
          "Sender"
        end
        
        def default_tax_number_label
          "VAT number:<br />"
        end
        
        def default_identifier_label
          "Invoice no.:"
        end
        
        def default_issue_date_label
          "Issue date:"
        end
        
        def default_period_start_label
          "Period from:"
        end
        
        def default_period_end_label
          "Period until:"
        end
        
        def default_due_date_label
          "Payment due:"
        end
        
        def default_address(details)
          html =  "#{indent*3}<div class=\"fn org\">#{       h(details[:name])        }</div>\n"
          html << "#{indent*3}<div class=\"contact\">#{      h(details[:contact_name])}</div>\n"        unless details[:contact_name].blank?
          html << "#{indent*3}<div class=\"adr\">\n"
          html << "#{indent*4}<span class=\"street-address\">#{h(details[:address]).strip.gsub(/\n/, '<br />')}</span><br />\n"
          html << "#{indent*4}<span class=\"locality\">#{    h(details[:city])        }</span><br />\n" unless details[:city].blank?
          html << "#{indent*4}<span class=\"region\">#{      h(details[:state])       }</span><br />\n" unless details[:state].blank?
          html << "#{indent*4}<span class=\"postal-code\">#{ h(details[:postal_code]) }</span><br />\n" unless details[:postal_code].blank?
          html << "#{indent*4}<span class=\"country-name\">#{h(details[:country])     }</span>\n"       unless details[:country].blank?
          html << "#{indent*3}</div>\n"
        end
        
        def default_sender_address
          invoke_address(get(:sender_details))
        end
        
        def default_recipient_address
          invoke_address(get(:recipient_details))
        end
        
        def default_sender_tax_number(params)
          sender_tax_number = get(:sender_details)[:tax_number]
          "#{params[:tax_number_label]}<span class=\"tax-number\">#{h(sender_tax_number)}</span>"
        end
        
        def default_recipient_tax_number(params)
          recipient_tax_number = get(:recipient_details)[:tax_number]
          "#{params[:tax_number_label]}<span class=\"tax-number\">#{h(recipient_tax_number)}</span>"
        end
        
        def default_addresses_table(params)
          html =  "#{indent*0}<table class=\"invoice addresses\">\n"
          html << "#{indent*1}<tr>\n"
          html << "#{indent*2}<th class=\"recipient\">#{params[:recipient_label]}</th>\n"
          html << "#{indent*2}<th class=\"sender\">#{params[:sender_label]}</th>\n"
          html << "#{indent*1}</tr>\n"
          html << "#{indent*1}<tr>\n"
          html << "#{indent*2}<td class=\"recipient vcard\">\n#{params[:recipient_address]}"
          html << "#{indent*2}</td>\n"
          html << "#{indent*2}<td class=\"sender vcard\">\n#{params[:sender_address]}"
          html << "#{indent*2}</td>\n"
          html << "#{indent*1}</tr>\n"
          html << "#{indent*1}<tr>\n"
          html << "#{indent*2}<td class=\"recipient\">\n"
          html << "#{indent*3}#{params[:recipient_tax_number]}\n"
          html << "#{indent*2}</td>\n"
          html << "#{indent*2}<td class=\"sender\">\n"
          html << "#{indent*3}#{params[:sender_tax_number]}\n"
          html << "#{indent*2}</td>\n"
          html << "#{indent*1}</tr>\n"
          html << "#{indent*0}</table>\n"
        end
        
        def default_metadata_item(params, key, value)
          label = params["#{key}_label".to_sym]
          html =  "#{indent*1}<tr class=\"#{key.to_s.gsub(/_/, '-')}\">\n"
          html << "#{indent*2}<th>#{label}</th>\n"
          html << "#{indent*2}<td>#{h(value)}</td>\n"
          html << "#{indent*1}</tr>\n"
        end
        
        def default_identifier(params)
          invoke_metadata_item(params, :identifier, get(:identifier))
        end
        
        def default_issue_date(params)
          if issue_date = get(:issue_date)
            invoke_metadata_item(params, :issue_date, issue_date.strftime(params[:date_format]))
          else
            ""
          end
        end
        
        def default_period_start(params)
          if period_start = get(:period_start)
            invoke_metadata_item(params, :period_start, period_start.strftime(params[:date_format]))
          else
            ""
          end
        end
        
        def default_period_end(params)
          if period_end = get(:period_end)
            invoke_metadata_item(params, :period_end, period_end.strftime(params[:date_format]))
          else
            ""
          end
        end
        
        def default_due_date(params)
          if due_date = get(:due_date)
            invoke_metadata_item(params, :due_date, due_date.strftime(params[:date_format]))
          else
            ""
          end
        end

        def default_metadata_table(params)
          "<table class=\"invoice metadata\">\n" + params[:identifier] + params[:issue_date] +
            params[:period_start] + params[:period_end] + params[:due_date] + "#{indent*0}</table>\n"
        end

#         def default_each_line_item(builder, line_item)
#           info = line_item.send(:line_item_class_info)
#           builder.tr do |tr|
#             tr.td info.get(line_item, :description)
#           end
#         end
        
        def default_page_layout(params)
          params[:title_tag] + params[:addresses_table] + params[:metadata_table]
        end
        
      end
    end
  end
end
