require 'rubygems'
require 'echoe'

# Add the project's top level directory and the lib directory to the Ruby search path
$: << File.expand_path(File.join(File.dirname(__FILE__), "lib"))
$: << File.expand_path(File.dirname(__FILE__))

require 'invoicing'

Echoe.new('invoicing', Invoicing::VERSION) do |p|
  p.summary = 'Ruby invoicing framework'
  p.description = 'Provides tools for applications which need to generate invoices for customers.'
  p.url = 'http://invoicing.rubyforge.org/'
  p.author = 'Martin Kleppmann'
  p.email = 'rubyforge@eptcomputing.com'
  p.dependencies = ['activerecord >=2.1.0']
end
