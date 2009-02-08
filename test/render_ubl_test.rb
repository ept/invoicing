# encoding: utf-8

require File.join(File.dirname(__FILE__), 'test_helper.rb')

class RenderUBLTest < Test::Unit::TestCase
  
  def reference_output(filename)
    IO.readlines(File.join(File.dirname(__FILE__), 'ref-output', filename)).join
  end
  
  def test_render_ubl
    assert_equal reference_output('invoice1.xml'), MyInvoice.find(1).render_ubl
  end
  
end