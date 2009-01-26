require File.join(File.dirname(__FILE__), 'test_helper.rb')

class TaxableTest < Test::Unit::TestCase
  
  class SimpleTaxLogic
    def apply_tax(params)
      if params[:attribute].to_s == 'amount'
        params[:value] * (BigDecimal('1.0') + params[:model_object].tax_factor)
      else
        params[:value]
      end
    end
    
    def remove_tax(params)
      if params[:attribute].to_s == 'amount'
        params[:value] / (BigDecimal('1.0') + params[:model_object].tax_factor)
      else
        params[:value]
      end
    end
    
    def tax_info(params)
      if params[:attribute].to_s == 'amount'
        "(inc. tax)"
      else
        ""
      end
    end
    
    def tax_details(params)
      if params[:attribute].to_s == 'amount'
        "(including #{sprintf('%.2f', 100*params[:model_object].tax_factor)}% tax)"
      else
        "(tax not applicable)"
      end
    end
  end

  class TaxableRecord < ActiveRecord::Base
    validates_numericality_of :amount
    acts_as_taxable :amount, :tax_logic => SimpleTaxLogic.new
  end
  
  def test_apply_tax_on_existing_record
    record = TaxableRecord.find(1)
    assert_equal record.gross_amount, record.amount_taxed
  end
  
  def test_remove_tax_on_existing_record
    record = TaxableRecord.find(1)
    record.amount_taxed = 114.29
    assert_equal BigDecimal('100.00'), record.amount
    record.save!
    assert_equal([{'amount' => '100.0000'}],
      ActiveRecord::Base.connection.select_all("SELECT amount FROM taxable_records WHERE id=1"))
  end
  
end
