require 'builder'

module Invoicing
  module LedgerItem
    # Included into ActiveRecord model object when +acts_as_ledger_item+ is invoked.
    module RenderUBL
      UBL_NAMESPACES = {
        "xmlns:cac" => "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2",
        "xmlns:cbc" => "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2",
        "xmlns:inv" => "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
      }
      
      def render_ubl
        info = ledger_item_class_info
        ubl = Builder::XmlMarkup.new
        ubl.instruct! :xml
        ubl.inv :Invoice, UBL_NAMESPACES do |invoice|
          invoice.cbc :ID, info.get(self, :identifier)
        end
        ubl.target!
      end
    end
  end
end
