require File.join(File.dirname(__FILE__), 'test_helper.rb')

####### Helper stuff

module LineItemMethods
  RENAMED_METHODS = {
    :id => :id2, :type => :type2, :ledger_item_id => :ledger_item_id2,
    :net_amount => :net_amount2, :tax_amount => :tax_amount2,
    :description => :description2, :uuid => :uuid2, :tax_point => :tax_point2,
    :tax_rate_id => :tax_rate_id2, :price_id => :price_id2,
    :quantity => :quantity2, :creator_id => :creator_id2, :ledger_item => :ledger_item2
  }
  
  def description2
    ""
  end
end


####### Classes for use in the tests (also used by LedgerItemTest)

class SuperLineItem < Invoicing::LineItem::Base
  set_table_name 'line_item_records'
  include LineItemMethods
  acts_as_line_item RENAMED_METHODS
  belongs_to :ledger_item2, :class_name => 'MyInvoice', :foreign_key => 'ledger_item_id2'
end

class SubLineItem < SuperLineItem
  
end

class OtherLineItem < Invoicing::LineItem::Base
  set_table_name 'line_item_records'
  include LineItemMethods
  acts_as_line_item RENAMED_METHODS
end

class NotSubclassLineItem < ActiveRecord::Base
  set_table_name 'line_item_records'
  include LineItemMethods
  acts_as_line_item RENAMED_METHODS
end


####### The actual tests

class LineItemTest < Test::Unit::TestCase
  
  def test_should_be_true
    assert_equal(1,1)
  end
  
end