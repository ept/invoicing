require 'activerecord'

Dir.glob(File.join(File.dirname(__FILE__), 'invoicing/**/*.rb')).sort.each {|f| require f }

ActiveRecord::Base.send(:extend, Invoicing::Tax::AttrTaxable)
ActiveRecord::Base.send(:extend, Invoicing::CachedRecord::ActMethods)
ActiveRecord::Base.send(:extend, Invoicing::TimeDependent::ActMethods)
ActiveRecord::Base.send(:extend, Invoicing::LedgerItem::ActMethods)
ActiveRecord::Base.send(:extend, Invoicing::CurrencyValue::ActMethods)
