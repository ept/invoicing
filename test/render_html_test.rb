# encoding: utf-8

require File.join(File.dirname(__FILE__), 'test_helper.rb')

class RenderHTMLTest < Test::Unit::TestCase

  def reference_output(filename)
    IO.readlines(File.join(File.dirname(__FILE__), 'ref-output', filename)).join
  end
  
  def test_render_default_html_invoice
    File.open(File.join(File.dirname(__FILE__), 'ref-output', 'debug1.html'), 'w') do |f|
      f.syswrite(MyInvoice.find(1).render_html)
    end
    assert_equal reference_output('invoice1.html'), MyInvoice.find(1).render_html
  end
  
end