Dir.glob(File.join(File.dirname(__FILE__), 'invoicing/**/*.rb')).sort.each {|f| require f }

require 'activerecord'

ActiveRecord::Base.send(:extend, Invoicing::Tax::AttrTaxable)
ActiveRecord::Base.send(:extend, Invoicing::CachedRecord::ActMethods)
ActiveRecord::Base.send(:extend, Invoicing::TimeDependent::ActMethods)
