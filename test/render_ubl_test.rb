# encoding: utf-8

require File.join(File.dirname(__FILE__), 'test_helper.rb')

class RenderUBLTest < Test::Unit::TestCase
  
  def reference_output(filename)
    IO.readlines(File.join(File.dirname(__FILE__), 'ref-output', filename)).join
  end
  
  def test_render_ubl_invoice
    assert_equal reference_output('invoice1.xml'), MyInvoice.find(1).render_ubl
  end
  
  def test_render_ubl_self_billed_invoice
    assert_equal reference_output('invoice2.xml'), MyInvoice.find(2).render_ubl
  end
  
  def test_render_ubl_credit_note
    #File.open(File.join(File.dirname(__FILE__), 'ref-output', 'debug3.xml'), 'w') do |f|
    #  f.syswrite(MyCreditNote.find(3).render_ubl)
    #end
    assert_equal reference_output('creditnote3.xml'),  MyCreditNote.find(3).render_ubl
  end
  
  def test_cannot_render_unknown_ledger_item_subtype
    assert_raise RuntimeError do
      CorporationTaxLiability.find(6).render_ubl
    end
  end
  
end