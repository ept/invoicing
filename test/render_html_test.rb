# encoding: utf-8

require File.join(File.dirname(__FILE__), 'test_helper.rb')

class RenderHTMLTest < Test::Unit::TestCase
  
  def test_render_html
    puts "\n\n\n"
    x = MyInvoice.find(1).render_html do |i|
      i.title_tag {|params| "<h1>#{params[:title_html]}</h1>\n" }
    end
    puts "#{x}\n\n\n"
  end
  
end