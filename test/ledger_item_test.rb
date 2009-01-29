require File.join(File.dirname(__FILE__), 'test_helper.rb')

####### Helper stuff

module LedgerItemMethods
  RENAMED_METHODS = {
    :id => :id2, :sender_id => :sender_id2, :recipient_id => :recipient_id2,
    :sender_details => :sender_details2, :recipient_details => :recipient_details2,
    :identifier => :identifier2, :issue_date => :issue_date2, :currency => :currency2,
    :total_amount => :total_amount2, :tax_amount => :tax_amount2, :status => :status2,
    :description => :description2, :period_start => :period_start2,
    :period_end => :period_end2, :uuid => :uuid2, :due_date => :due_date2
  }
  
  def sender_details2
    {}
  end
  
  def recipient_details2
    {}
  end
  
  def description2
    ""
  end
end


####### Classes for use in the tests

class MyInvoice < Invoicing::LedgerItem::Invoice
  set_table_name 'ledger_item_records'
  include LedgerItemMethods
  acts_as_ledger_item RENAMED_METHODS
end

class InvoiceSubtype < MyInvoice
  
end

class MyCreditNote < Invoicing::LedgerItem::CreditNote
  set_table_name 'ledger_item_records'
  include LedgerItemMethods
  acts_as_ledger_item RENAMED_METHODS
end

class MyPayment < Invoicing::LedgerItem::Payment
  set_table_name 'ledger_item_records'
  include LedgerItemMethods
  acts_as_ledger_item RENAMED_METHODS
end

class NotSubclassOfLedgerItem < ActiveRecord::Base
  set_table_name 'ledger_item_records'
  include LedgerItemMethods
  acts_as_ledger_item RENAMED_METHODS
end

class CorporationTaxLiability < Invoicing::LedgerItem::Base
  set_table_name 'ledger_item_records'
  include LedgerItemMethods
  acts_as_ledger_item RENAMED_METHODS
end


####### The actual tests

class LedgerItemTest < Test::Unit::TestCase
  
  def test_should_be_true
    assert_nil InvoiceSubtype.first
  end
  
end