require File.join(File.dirname(__FILE__), 'test_helper.rb')

class TaxableTest < Test::Unit::TestCase
  
  class SimpleTaxLogic
    def display_price_to_user(params)
      if params[:method].to_sym == :amount
        params[:value] * (BigDecimal('1.0') + params[:model_object].tax_factor)
      else
        params[:value]
      end
    end
    
    def input_price_from_user(params)
      if params[:method].to_sym == :amount
        params[:value] / (BigDecimal('1.0') + params[:model_object].tax_factor)
      else
        params[:value]
      end
    end
  end

  class TaxableRecord < ActiveRecord::Base
    validates_numericality_of :amount
    acts_as_taxable :amount, :tax_logic => SimpleTaxLogic.new
  end
  
  def test_taxed_suffix
    record = TaxableRecord.find(1)
    assert_equal record.gross_amount, record.amount_taxed
  end
  
end
