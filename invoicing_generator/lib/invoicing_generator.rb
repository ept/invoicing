[
  File.dirname(__FILE__),
  File.join(File.dirname(__FILE__), '..', '..', 'invoicing', 'lib')
].each do |dir|
  unless !File.exists?(dir) || $:.include?(dir) || $:.include?(File.expand_path(dir))
    $:.unshift dir
  end
end

require 'invoicing'

module InvoicingGenerator
  VERSION = Invoicing::VERSION
end
