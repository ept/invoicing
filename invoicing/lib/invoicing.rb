$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'active_record'

require 'invoicing/class_info'  # load first because other modules depend on this
Dir.glob(File.join(File.dirname(__FILE__), 'invoicing/**/*.rb')).sort.each {|f| require f }

# Mix all modules Invoicing::*::ActMethods into ActiveRecord::Base as class methods
Invoicing.constants.map{|c| Invoicing.const_get(c) }.select{|m| m.is_a?(Module) && m.const_defined?('ActMethods') }.each{
  |m| ActiveRecord::Base.send(:extend, m.const_get('ActMethods'))
}
