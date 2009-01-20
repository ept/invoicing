require File.join(File.dirname(__FILE__), 'test_helper.rb')

class LedgerItemTest < Test::Unit::TestCase
  
  class NotSubclassOfLedgerItem < ActiveRecord::Base
    set_table_name 'ledger_item_records'
    acts_as_ledger_item
  end
  
  class CorporationTaxLiability < Invoicing::LedgerItem::Base
    set_table_name 'ledger_item_records'
  end
  
   

  def test_should_be_true
    assert_equal(1,1)
  end
  
end