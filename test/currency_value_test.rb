require File.join(File.dirname(__FILE__), 'test_helper.rb')

class CurrencyValueTest < Test::Unit::TestCase

  class CurrencyValueRecord < ActiveRecord::Base
    attr_currency_value :amount, :tax_amount, :currency => 'currency_code'
  end

  def test_something
    assert true
  end

end
