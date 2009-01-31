require File.join(File.dirname(__FILE__), 'test_helper.rb')

####### Helper stuff

module LedgerItemMethods
  RENAMED_METHODS = {
    :id => :id2, :sender_id => :sender_id2, :recipient_id => :recipient_id2,
    :sender_details => :sender_details2, :recipient_details => :recipient_details2,
    :identifier => :identifier2, :issue_date => :issue_date2, :currency => :currency2,
    :total_amount => :total_amount2, :tax_amount => :tax_amount2, :status => :status2,
    :description => :description2, :period_start => :period_start2,
    :period_end => :period_end2, :uuid => :uuid2, :due_date => :due_date2,
    :line_items => :line_items2
  }
  
  def user_id_to_details_hash(user_id)
    case user_id
      when 1, nil
        {:is_self => true, :name => 'Unlimited Limited', :contact_name => "Mr B. Badger",
         :address => "The Sett\n5 Badger Lane\n", :city => "Badgertown", :state => "",
         :postal_code => "Badger999", :country => "England", :country_code => "GB",
         :vat_number => "123456789"}
      when 2
        {:name => 'Lovely Customer Inc.', :contact_name => "Fred",
         :address => "The pasture", :city => "Mootown", :state => "Cow Kingdom",
         :postal_code => "MOOO", :country => "Scotland", :country_code => "GB",
         :vat_number => "987654321"}
      when 3
        {:name => 'I drink milk', :address => "Guzzle guzzle", :city => "Cheesetown",
         :postal_code => "12345", :country => "United States", :country_code => "US"}
      when 4
        {:name => 'The taxman', :address => "ALL YOUR EARNINGS\r\n\tARE BELONG TO US",
         :city => 'Cumbernauld', :state => 'North Lanarkshire', :postal_code => "",
         :country => 'United Kingdom'}
    end
  end
  
  def sender_details2
    user_id_to_details_hash(sender_id2)
  end
  
  def recipient_details2
    user_id_to_details_hash(recipient_id2)
  end
  
  def description2
    "#{type} #{id2}"
  end
end


####### Classes for use in the tests

class MyInvoice < Invoicing::LedgerItem::Invoice
  set_primary_key 'id2'
  set_table_name 'ledger_item_records'
  include LedgerItemMethods
  acts_as_ledger_item RENAMED_METHODS
  has_many :line_items2, :class_name => 'SuperLineItem', :foreign_key => 'ledger_item_id2'
end

class InvoiceSubtype < MyInvoice
end

class MyCreditNote < Invoicing::LedgerItem::CreditNote
  set_primary_key 'id2'
  set_table_name 'ledger_item_records'
  include LedgerItemMethods
  acts_as_ledger_item RENAMED_METHODS
end

class MyPayment < Invoicing::LedgerItem::Payment
  set_primary_key 'id2'
  set_table_name 'ledger_item_records'
  include LedgerItemMethods
  acts_as_ledger_item RENAMED_METHODS
end

class NotSubclassOfLedgerItem < ActiveRecord::Base
  set_primary_key 'id2'
  set_table_name 'ledger_item_records'
  include LedgerItemMethods
  acts_as_ledger_item RENAMED_METHODS
end

class CorporationTaxLiability < Invoicing::LedgerItem::Base
  set_primary_key 'id2'
  set_table_name 'ledger_item_records'
  include LedgerItemMethods
  acts_as_ledger_item RENAMED_METHODS
end

class UUIDNotPresent < ActiveRecord::Base
  set_primary_key 'id2'
  set_table_name 'ledger_item_records'
  include LedgerItemMethods
  
  def get_class_info
    ledger_item_class_info
  end
end

class OverwrittenMethodsNotPresent < Invoicing::LedgerItem::Invoice
  set_primary_key 'id2'
  set_table_name 'ledger_item_records'
  acts_as_ledger_item LedgerItemMethods::RENAMED_METHODS
end


####### The actual tests

class LedgerItemTest < Test::Unit::TestCase
  
  def test_total_amount_is_currency_value
    record = NotSubclassOfLedgerItem.find(5)
    assert_equal '$432.10', record.total_amount2_formatted
  end
  
  def test_tax_amount_is_currency_value
    record = MyInvoice.find(1)
    assert_equal '£15.00', record.tax_amount2_formatted
  end
  
  def test_sent_by_nil_is_treated_as_self
    assert MyInvoice.find(1).sent_by?(nil)
    assert MyCreditNote.find(3).sent_by?(nil)
  end
  
  def test_received_by_nil_is_treated_as_self
    assert InvoiceSubtype.find(2).received_by?(nil)
    assert CorporationTaxLiability.find(6).received_by?(nil)
  end
  
  def test_invoice_from_self_is_debit
    record = MyInvoice.find(1)
    assert_kind_of Invoicing::LedgerItem::Invoice, record
    assert record.debit?(1)
    assert record.debit?(nil)
  end
  
  def test_invoice_to_self_is_credit
    record = InvoiceSubtype.find(2)
    assert_kind_of Invoicing::LedgerItem::Invoice, record
    assert !record.debit?(1)
    assert !record.debit?(nil)
  end
  
  def test_invoice_to_customer_is_seen_as_credit_by_customer
    assert !MyInvoice.find(1).debit?(2)
  end
  
  def test_invoice_from_supplier_is_seen_as_debit_by_supplier
    assert InvoiceSubtype.find(2).debit?(2)
  end
  
  def test_credit_note_from_self_is_credit
    record = MyCreditNote.find(3)
    assert_kind_of Invoicing::LedgerItem::CreditNote, record
    assert !record.debit?(nil)
  end
  
  def test_credit_note_to_customer_is_seen_as_debit_by_customer
    assert MyCreditNote.find(3).debit?(2)
  end
  
  def test_payment_receipt_from_self_is_credit
    record = MyPayment.find(4)
    assert_kind_of Invoicing::LedgerItem::Payment, record
    assert !record.debit?(1)
    assert !record.debit?(nil)
  end
  
  def test_payment_receipt_to_customer_is_seen_as_debit_by_customer
    assert MyPayment.find(4).debit?(2)
  end
  
  def test_cannot_determine_debit_status_for_uninvolved_party
    assert_raise ArgumentError do
      MyInvoice.find(1).debit?(3)
    end
  end
  
  def test_cannot_determine_debit_status_for_custom_ledger_item_type
    assert_raise RuntimeError do
      NotSubclassOfLedgerItem.find(5).debit?(2)
    end
  end
  
  def test_assign_uuid_to_new_record
    record = MyInvoice.new
    begin
      UUID
      uuid_gem_available = true
    rescue NameError
      uuid_gem_available = false
    end
    if uuid_gem_available
      assert_match /^[0-9a-f]{8}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{12}$/, record.uuid2
    else
      assert record.uuid2.blank?
      puts "Warning: uuid gem not installed -- not testing UUID generation"
    end
  end
  
  def test_uuid_gem_not_present
    begin
      real_uuid = Object.send(:remove_const, :UUID)
      UUIDNotPresent.acts_as_ledger_item(LedgerItemMethods::RENAMED_METHODS)
      assert_nil UUIDNotPresent.new.get_class_info.uuid_generator
    ensure
      Object.send(:const_set, :UUID, real_uuid)
    end
  end
  
  def test_must_overwrite_sender_details
    assert_raise RuntimeError do
      OverwrittenMethodsNotPresent.new.sender_details
    end
  end
  
  def test_must_overwrite_recipient_details
    assert_raise RuntimeError do
      OverwrittenMethodsNotPresent.new.recipient_details
    end
  end
  
  def test_must_provide_line_items_association
    assert_raise RuntimeError do
      OverwrittenMethodsNotPresent.new.line_items
    end
  end
  
  def test_calculate_total_amount_for_new_invoice
    invoice = MyInvoice.new(:currency2 => 'USD')
    invoice.line_items2 << SuperLineItem.new(:net_amount2 => 100, :tax_amount2 => 15)
    invoice.line_items2 << SubLineItem.new(:net_amount2 => 10)
    invoice.valid?
    assert_equal BigDecimal('125'), invoice.total_amount
    assert_equal BigDecimal('15'), invoice.tax_amount
  end
  
  def test_line_items_error
    assert_raise RuntimeError do
      MyInvoice.find(1).line_items # not line_items2
    end
  end
  
end
