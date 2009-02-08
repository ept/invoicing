# encoding: utf-8

require File.join(File.dirname(__FILE__), 'test_helper.rb')

class RenderUBLTest < Test::Unit::TestCase
  
  def test_render_ubl
    puts "\n\n\n#{MyInvoice.find(1).render_ubl}\n\n\n"
  end
  
end