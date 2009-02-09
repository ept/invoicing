# encoding: utf-8

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
    "moo"
  end
end


####### Classes for use in the tests (also used by LedgerItemTest)

class SuperLineItem < ActiveRecord::Base
  set_primary_key 'id2'
  set_inheritance_column 'type2'
  set_table_name 'line_item_records'
  include LineItemMethods
  acts_as_line_item RENAMED_METHODS
  belongs_to :ledger_item2, :class_name => 'MyLedgerItem', :foreign_key => 'ledger_item_id2'
end

class SubLineItem < SuperLineItem
  def description2
    "this is the SubLineItem"
  end
end

class OtherLineItem < SuperLineItem
end

class UntaxedLineItem < SuperLineItem
end

class UUIDNotPresentLineItem < ActiveRecord::Base
  set_primary_key 'id2'
  set_inheritance_column 'type2'
  set_table_name 'line_item_records'
  include LineItemMethods
  
  def get_class_info
    line_item_class_info
  end
end

class OverwrittenMethodsNotPresentLineItem < ActiveRecord::Base
  set_primary_key 'id2'
  set_inheritance_column 'type2'
  set_table_name 'line_item_records'
  acts_as_line_item LineItemMethods::RENAMED_METHODS
end


####### The actual tests

class LineItemTest < Test::Unit::TestCase
  
  def test_net_amount_is_currency_value
    assert_equal '$432.10', UntaxedLineItem.find(4).net_amount2_formatted
  end
  
  def test_tax_amount_is_currency_value
    assert_equal '£15.00', SuperLineItem.find(1).tax_amount2_formatted
  end
  
  def test_gross_amount
    assert_equal BigDecimal('115'), SuperLineItem.find(1).gross_amount
  end

  def test_gross_amount_formatted
    assert_equal '£115.00', SuperLineItem.find(1).gross_amount_formatted
  end
  
  def test_assign_uuid_to_new_record
    record = SuperLineItem.new
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
      UUIDNotPresentLineItem.acts_as_line_item(LineItemMethods::RENAMED_METHODS)
      assert_nil UUIDNotPresentLineItem.new.get_class_info.uuid_generator
    ensure
      Object.send(:const_set, :UUID, real_uuid)
    end
  end

  def test_must_provide_ledger_item_association
    assert_raise RuntimeError do
      OverwrittenMethodsNotPresentLineItem.new.ledger_item
    end
  end

  def test_ledger_item_error
    assert_raise RuntimeError do
      SuperLineItem.find(1).ledger_item # not ledger_item2
    end
  end
  
  def test_currency
    assert_equal 'GBP', SubLineItem.find(2).currency
  end
  
  def test_in_effect_scope
    assert_equal [1,2,3,4,5,6,7,8], SuperLineItem.all.map{|i| i.id}.sort
    assert_equal [1,2,3,4,5,6], SuperLineItem.in_effect.map{|i| i.id}.sort
  end
  
  def test_sorted_scope
    assert_equal [4,2,1,5,3,6,7,8], SuperLineItem.sorted(:tax_point).map{|i| i.id}
  end
  
  def test_sorted_scope_with_non_existent_column
    assert_equal [1,2,3,4,5,6,7,8], SuperLineItem.sorted(:this_column_does_not_exist).map{|i| i.id}
  end
  
end