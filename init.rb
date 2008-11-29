ActiveRecord::Base.send(:extend, Ept::Invoicing::ActiveRecordMethods)
ActiveRecord::Base.send(:extend, Ept::Invoicing::Tax::TaxCategory)
