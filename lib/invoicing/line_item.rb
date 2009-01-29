module Invoicing
  # = Line item objects
  #
  # A line item is a single charge on an invoice or credit note, for example representing the sale
  # of one particular product. An invoice or credit note with a non-zero +total_amount+ must have at
  # least one +LineItem+ object associated with it, and its +total_amount+ must equal the sum of the
  # +net_amount+ and +tax_amount+ values of all +LineItem+ objects associated with it. For details
  # on invoices and credit notes, see the +LedgerItem+ module.
  #
  # Many of the important principles set down in the +LedgerItem+ module also apply for line items.
  #
  # == Using +LineItem+
  #
  # In all likelihood you will have different types of charges which you need to make to your customers.
  # We store all those different types of line item in the same database table and use ActiveRecord's
  # single table inheritance to build a class hierarchy. Your base class for line items should be
  # <tt>Invoicing::LineItem::Base</tt>, like this:
  #
  #   class ProductSale < Invoicing::LineItem::Base
  #     set_table_name 'line_items'
  #     belongs_to :product
  #     
  #     def description
  #       product.title
  #     end
  #   end
  #   
  #   class ShippingCharges < Invoicing::LineItem::Base
  #     set_table_name 'line_items'
  #     
  #     def description
  #       "Shipping charges"
  #     end
  #   end
  #
  # You may associate line items of any type with credit notes and invoices interchangeably. This means,
  # for example, that if you overcharge a customer for shipping, you can send them a credit note with
  # a +ShippingCharges+ line item, thus making it explicit what it is you are refunding. +Payment+ records
  # usually do not have any associated line items.
  #
  # == Required methods/database columns
  #
  # The following methods/database columns are <b>required</b> for +LineItem+ objects (you may give them
  # different names, but then you need to tell +acts_as_line_item+ about your custom names):
  #
  # +type+::
  #   String to store the class name, for ActiveRecord single table inheritance.
  #  
  # +ledger_item_id+::
  #   A foreign key of integer type, which references another model class in your application; that
  #   model class must be a subclass of <tt>Invoicing::LedgerItem::Base</tt> or call +acts_as_ledger_item+.
  #   It represents the invoice or credit note to which this line item belongs. +acts_as_line_item+ will
  #   automatically create a +belongs_to+ association called +ledger_item+.
  #
  # +net_amount+::
  #   A decimal column containing the monetary amount charged by this line item, not including tax.
  #   The currency is not explicitly specified on the line item, but is taken to be the currency of the
  #   invoice or credit note to which it belongs. (This is deliberate, because you mustn't mix different
  #   currencies within one invoice.) See the documentation of the +CurrencyValue+ module for notes on
  #   suitable datatypes for monetary values. +acts_as_currency_value+ is automatically applied to this
  #   attribute.
  #   
  # +tax_amount+::
  #   A decimal column containing the monetary amount of tax which is added to +net_amount+ to obtain
  #   the total price. This may of course be zero. +CurrencyValue+ applies as with +net_amount+.
  #   If you have several different taxes being applied, please check with your accountant. We suggest
  #   that you put VAT or sales tax in this +tax_amount+ column, and any other taxes (e.g. duty on
  #   alcohol or tobacco) in separate line items. If you are not obliged to pay tax, lucky you --
  #   put zeroes in this column and await the day when you have enough business that you *do* have to
  #   pay tax.
  #
  # +description+::
  #   A method which returns a short string explaining to your user what this line item is for.
  #   Can be a database column but doesn't have to be.
  #  
  # == Optional methods/database columns
  #
  # The following methods/database columns are <b>optional, but recommended</b> for +LineItem+ objects:
  #
  # +uuid+::
  #   A Universally Unique Identifier (UUID)[http://en.wikipedia.org/wiki/UUID] string for this line item.
  #   It may seem unnecessary now, but may help you to keep track of your data later on as your system
  #   grows. If you have the +uuid+ gem installed and this column is present, a UUID is automatically
  #   generated when you create a new line item.
  #
  # +tax_point+::
  #   A datetime column which indicates the date on which the sale is made and/or the service is provided.
  #   It is related to the +issue_date+ on the associated invoice/credit note, but does not necessarily
  #   have the same value. The exact technicalities will vary by jurisdiction, but generally this is the
  #   point in time which determines into which month or which tax period you count a sale. The value may
  #   be the same as +created_at+ or +updated_at+, but not necessarily.
  #
  # +tax_rate_id+::
  #   A foreign key of integer type, referencing another model class in your application which represents
  #   the tax rate applied to this line item. The tax rate model object should use +acts_as_tax_rate+.
  #   This attribute is necessary if you want tax calculations to be performed automatically.
  #
  # +price_id+::
  #   A foreign key of integer type, referencing another model class in your application which represents
  #   the unit price (e.g. a reference to a the product, or to a particular price band of a service). The
  #   model object thus referred to should use +acts_as_price+. This attribute allows you to get better
  #   reports of how much you sold of what.
  #
  # +quantity+::
  #   A numeric (integer or decimal) type, saying how many units of a particular product or service this
  #   line item represents. Default is 1. Note that if you specify a +quantity+, the values for +net_amount+
  #   and +tax_amount+ must be the cost of the given quantity as a whole; if you need to display the unit
  #   price, you can get it by dividing +net_amount+ by +quantity+, or by referring to +price_id+.
  #
  # +creator_id+::
  #   The ID of the user whose action caused this line item to be created or updated. This can be useful
  #   for audit trail purposes, particularly if you allow multiple users of your application to act on
  #   behalf of the same customer organisation.
  #
  # +created_at+, +updated_at+::
  #   These standard datetime columns are also recommended.
  #
  module LineItem
    module ActMethods
      def acts_as_line_item(*args)
        
      end
    end
    
    
    class Base < ActiveRecord::Base
      
      def initialize(*args)
        super
        # Initialise uuid attribute if possible
        info = line_item_class_info
        if self.has_attribute?(info.method(:uuid)) && info.uuid_generator
          write_attribute(info.method(:uuid), info.uuid_generator.generate)
        end
      end
    end
    
    
    class ClassInfo < Invoicing::ClassInfo::Base #:nodoc:
      attr_reader :uuid_generator
      
      def initialize(model_class, previous_info, args)
        super
        
        @uuid_generator = nil
        begin # try to load the UUID gem
          require 'uuid'
          @uuid_generator = UUID.new
        rescue LoadError, NameError # silently ignore if gem not found
        end
      end
    end
  end
end