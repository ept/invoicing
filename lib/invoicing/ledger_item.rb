module Invoicing
  # = Ledger item objects
  #
  # This module implements a simple ledger, i.e. the record of all of the business transactions
  # which are handled by your application. Each transaction is recorded as one +LedgerItem+ object,
  # each of which may have one of the following three types:
  #
  # +Invoice+::
  #   When you send an invoice to someone (= a customer), this is a record of the fact
  #   that you have sold them something (a product, a service etc.), and how much you expect to be
  #   paid for it. An invoice can consist of a list of individual charges, but it is considered as
  #   one document for legal purposes. You can also create invoices from someone else to yourself,
  #   if you owe someone else money -- for example, if you need to pay commissions to a reseller of
  #   your application.
  # +CreditNote+::
  #   This is basically a negative invoice; you should use it if you have previously
  #   sent a customer an invoice with an amount which was too great (i.e. you have overcharged them).
  #   Note that the numeric value on a credit note is positive; this value is subtracted from the
  #   amount which the recipient owes to the sender. For example, if you send a customer an invoice
  #   with a +total_amount+ of $20 and a credit note with a +total_amount+ of $10 (not -$10!), that
  #   means that you're asking them to pay $10.
  # +Payment+::
  #   This is a record of the fact that a payment has been made. It's a simple object,
  #   in effect just saying that party A paid amount X to party B on date Y.
  #
  # == Important principles
  #
  # Note the distinction between Invoices/Credit Notes and Payments; to keep your accounts clean,
  # it is important that you do not muddle these up.
  #
  # * <b>Invoices and Credit Notes</b> are the important documents for tax purposes in most
  #   jurisdictions. They record the date on which the sale is officially made, and that date
  #   determines which tax rates apply. An invoice often also represents the transfer of ownership from
  #   the supplier to the customer; for example, if you ask your customers to send payment in
  #   advance (such as 'topping up' their account), that money still belongs to your customer
  #   until the point where they have used your service, and you have charged them for your
  #   service by sending them an invoice. You should only invoice them for what they have actually
  #   used, then the remaining balance will automatically be retained on their account.
  # * <b>Payments</b> are just what it says on the tin -- the transfer of money from one hand
  #   to another. A payment may occur before an invoice is issued (payment in advance), or
  #   after/at the same time as an invoice is issued to settle the debt (payment in arrears, giving
  #   your customers credit). You can choose whatever makes sense for your business.
  #   Payments may often be associated one-to-one with invoices, but not necessarily -- an invoice
  #   may be paid in instalments, or several invoices may be lumped together to one payment. Your
  #   customer may even refuse to pay some charges, in which case there is an invoice but no payment
  #   (until at some point you either reverse it with a credit note, or write it off as bad debt,
  #   but that's beyond our scope right now).
  #
  # Another very important principle is that once a piece of information has been added to the
  # ledger, you <b>should not modify or delete it</b>. Particularly when you have 'sent' one of your
  # customers or suppliers a document (which may mean simply that they have seen it on the web) you should
  # not change it again, because they might have added that information to their own accounting system.
  # Changing any information is guaranteed to lead to confusion. (The model objects do not restrict your
  # editing capabilities because they might be necessary in specific circumstances, but you should be
  # extremely careful when changing anything.)
  #
  # Of course you make mistakes or change your mind, but please deal with them cleanly:
  # * If you create an invoice whose value is too small, don't amend the invoice, but send them
  #   another invoice to cover the remaining amount.
  # * If you create an invoice whose value is too great (for example because you want to offer one
  #   customer a special discount), don't amend the invoice, but send them a credit note to waive
  #   your claim to the difference.
  # * If you create a payment, mark it as +pending+ until it the money has actually arrived.
  #   If it never arrives, mark the payment as +failed+.
  #
  # The exception are invoices on which you accumulate charges (e.g. over the course of a month)
  # and then officially 'send' the invoice at the end of the period. In this gem we call such
  # invoices +open+ while they may still be changed. It's ok to add charges to +open+ invoices
  # as you go along; while it is +open+ it is not legally an invoice, but only a statement
  # of accumulated charges. If you display it to users, make sure that you don't call it "invoice",
  # to avoid confusion. Only when you set it to +closed+ at the end of the month does the
  # statement become an invoice for legal purposes. Once it's +closed+ you must not add
  # any further charges to it.
  #
  # Finally, please only use positive numeric values on invoices, credit notes and payments (unless
  # you have specifically been given other instructions by your accountant). Use the +sender_id+
  # and +recipient_id+ fields to indicate the direction of a transaction (see below).
  #
  # == Using invoices, credit notes and payments in your application
  #
  # All invoices, credit notes and payments (collectively called 'ledger items') are stored in a
  # single database table. We use <b>single table inheritance</b> to distinguish the object types:
  # this module provides a base class type <tt>Invoicing::LedgerItem::Base < ActiveRecord::Base</tt>
  # and three subclasses:
  # <tt>Invoicing::LedgerItem::Invoice</tt>::    base class for all types of invoice
  # <tt>Invoicing::LedgerItem::CreditNote</tt>:: base class for all types of credit note
  # <tt>Invoicing::LedgerItem::Payment</tt>::    base class for all types of payment
  #
  # You can create as many subclasses as you like of each of these three types. This provides a
  # convenient mechanism for encapsulating different types of functionality which you may need for
  # different types of transactions, but still keeping the accounts in one place. You may start
  # with only one type of invoice (e.g. <tt>class MonthlyChargesInvoice < Invoicing::LedgerItem::Invoice</tt>
  # to bill users for their use of your application; but as you want to do more clever things, you
  # can add other subclasses of +Invoice+ as and when you need them (such as +ConsultancyServicesInvoice+
  # and +SalesCommissionInvoice+, for example). Similarly for payments, you may have subclasses representing
  # credit card payments, cash payments, bank transfers etc.
  #
  # You must create at least one subclass of each of +Invoice+, +CreditNote+ and +Payment+ and assign
  # them the same ActiveRecord table name (using <tt>ActiveRecord::Base.set_table_name</tt>). That
  # database table must have a certain minimum set of columns and a few common methods, documented
  # below (although you may rename any of them if you wish). Beyond those, you may add other methods and
  # database columns for your application's own needs, provided they don't interfere with names used here.
  #
  # == Required methods/database columns
  #
  # The following methods/database columns are <b>required</b> for +LedgerItem+ objects (you may give them
  # different names, but then you need to tell +acts_as_ledger_item+ about your custom names):
  #
  # +type+::
  #   String to store the class name, for ActiveRecord single table inheritance.
  #
  # +sender_id+::
  #   Integer-valued foreign key, used to refer to some other model object representing the party
  #   (person, company etc.) who is the sender of the transaction.
  #   - In the case of an invoice or credit note, the +sender_id+ identifies the supplier of the product or service,
  #     i.e. the person who is owed the amount specified on the invoice, also known as the creditor.
  #   - In the case of a payment record, the +sender_id+ identifies the payee, i.e. the person who sends the note
  #     confirming that they received payment.
  #   - This field may be +NULL+ to refer to yourself (i.e. the company/person who owns or
  #     operates this application), but you may also use non-+NULL+ values to refer to yourself. It's just
  #     important that you consistently refer to the same party by the same value in different ledger items.
  #
  # +recipient_id+::
  #   The counterpart to +sender_id+: foreign key to a model object which represents the
  #   party who is the recipient of the transaction.
  #   - In the case of an invoice or credit note, the +recipient_id+ identifies the customer/buyer of the product or
  #     service, i.e. the person who owes the amount specified on the invoice, also known as the debtor.
  #   - In the case of a payment record, the +recipient_id+ identifies the payer, i.e. the recipient of the
  #     payment receipt.
  #   - +NULL+ may be used as in +sender_id+.
  #
  # +sender_details+::
  #   A method (does not have to be a database column) which returns a hash with information
  #   about the party identified by +sender_id+. See the documentation of +sender_details+ for the expected
  #   contents of the hash. Must always return valid details, even if +sender_id+ is +NULL+.
  #
  # +recipient_details+::
  #   A method (does not have to be a database column) which returns a hash with information
  #   about the party identified by +recipient_id+. See the documentation of +sender_details+ for the expected
  #   contents of the hash (+recipient_details+ uses the same format as +sender_details+). Must always
  #   return valid details, even if +recipient_id+ is +NULL+.
  #
  # +identifier+::
  #   A number or string used to identify this record, i.e. the invoice number, credit note number or
  #   payment receipt number as appropriate.
  #   - There may be legal requirements in your country concerning its format, but as long as it uniquely identifies
  #     the document within your organisation you should be safe.
  #   - It's possible to simply make this an alias of the primary key, but it's strongly recommended that you use a
  #     separate database column. If you ever need to generate invoices on behalf of other people (i.e. where
  #     +sender_id+ is not you), you need to give the sender of the invoice the opportunity to enter their own
  #     +identifier+ (because it then must be unique within the sender's organisation, not yours).
  #
  # +issue_date+::
  #   A datetime column which indicates the date on which the document is issued, and which may also
  #   serve as the tax point (the date which determines which tax rate is applied). This should be a separate
  #   column, because it won't necessarily be the same as +created_at+ or +updated_at+. There may be business
  #   reasons for choosing particular dates, but the date at which you send the invoice or receive the payment
  #   should do unless your accountant advises you otherwise.
  #
  # +currency+::
  #   The 3-letter code which identifies the currency used in this transaction; must be one of the list
  #   of codes in ISO-4217[http://en.wikipedia.org/wiki/ISO_4217]. (Even if you only use one currency throughout
  #   your site, this is needed to format monetary amounts correctly.)
  #
  # +total_amount+::
  #   A decimal column containing the grand total monetary sum (of the invoice or credit note), or the monetary
  #   amount paid (of the payment record), including all taxes, charges etc. For invoices and credit notes, a
  #   +before_validation+ filter is automatically invoked, which adds up the +net_amount+ and +tax_amount+ values
  #   of all line items and assigns that sum to +total_amount+. For payment records, which do not usually have
  #   line items, you must assign the correct value to this column. See the documentation of the +CurrencyValue+
  #   module for notes on suitable datatypes for monetary values. +acts_as_currency_value+ is automatically applied
  #   to this attribute.
  #
  # +tax_amount+::
  #   If you're a small business you maybe don't need to add tax to your invoices; but if you are successful,
  #   you almost certainly will need to do so eventually. In most countries this takes the form of Value Added
  #   Tax (VAT) or Sales Tax. For invoices and credit notes, you must store the amount of tax in this table;
  #   a +before_validation+ filter is automatically invoked, which adds up the +tax_amount+ values of all
  #   line items and assigns that sum to +total_amount+. For payment records this should be zero (unless you
  #   use a cash accounting scheme, which is currently not supported). See the documentation of the
  #   +CurrencyValue+ module for notes on suitable datatypes for monetary values. +acts_as_currency_value+ is
  #   automatically applied to this attribute.
  #
  # +status+::
  #   A string column used to keep track of the status of ledger items. Currently the following values are defined
  #   (but future versions may add further +status+ values):
  #   +open+::      For invoices/credit notes: the document is not yet finalised, further line items may be added.
  #   +closed+::    For invoices/credit notes: the document has been sent to the recipient and will not be changed again.
  #   +cancelled+:: For invoices/credit notes: the document has been declared void and does not count towards accounts.
  #   +pending+::   For payments: payment is expected or has been sent, but has not yet been confirmed as received.
  #   +cleared+::   For payments: payment has completed successfully.
  #   +failed+::    For payments: payment did not succeed; this record is not counted towards accounts.
  #
  # +description+::
  #   A method which returns a short string describing what this invoice, credit note or payment is about.
  #   Can be a database column but doesn't have to be.
  #
  #
  # == Optional methods/database columns
  #
  # The following methods/database columns are <b>optional, but recommended</b> for +LedgerItem+ objects:
  #
  # +period_start+, +period_end+::
  #   Two datetime columns which define the period of time covered by an invoice or credit note. If the thing you
  #   are selling is a one-off, you can omit these columns or leave them as +NULL+. However, if there is any sort
  #   of duration associated with an invoice/credit note (e.g. charges incurred during a particular month, or
  #   an annual subscription, or a validity period of a license, etc.), please store that period here. It's
  #   important for accounting purposes. (For +Payment+ objects it usually makes most sense to just leave these
  #   as +NULL+.)
  #
  # +uuid+::
  #   A Universally Unique Identifier (UUID)[http://en.wikipedia.org/wiki/UUID] string for this invoice, credit
  #   note or payment. It may seem unnecessary now, but may help you to keep track of your data later on as
  #   your system grows. If you have the +uuid+ gem installed and this column is present, a UUID is automatically
  #   generated when you create a new ledger item.
  #
  # +due_date+::
  #   The date at which the invoice or credit note is due for payment. +nil+ on +Payment+ records.
  #
  # +created_at+, +updated_at+::
  #   The standard ActiveRecord datetime columns for recording when an object was created and last changed.
  #   The values are not directly used at the moment, but it's useful information in case you need to track down
  #   a particular transaction sometime; and ActiveRecord manages them for you anyway.
  #
  #
  # == Generated methods
  #
  # In return for providing +LedgerItem+ with all the required information as documented above, you are given
  # a number of class and instance methods which you will find useful sooner or later. In addition to those
  # documented in this module, the following methods are generated dynamically:
  #
  # * FIXME describe dynamically generated methods
  module LedgerItem
    
    module ActMethods
      # Declares that the current class is a model for ledger items (i.e. invoices, credit notes and
      # payment notes). It is recommended that instead of using +acts_as_ledger_item+, you make your
      # invoice, credit note and payment classes subclasses of <tt>Invoicing::LedgerItem::Invoice</tt>,
      # <tt>Invoicing::LedgerItem::CreditNote</tt> and <tt>Invoicing::LedgerItem::Payment</tt> instead.
      # Use +acts_as_ledger_item+ only if you cannot change your existing class hierarchy (which may be
      # the case if you are retrofitting this invoicing framework to your existing application), or if
      # you have multiple disjoint hierarchies of ledger items in different tables (although I can't
      # imagine why anybody would want to do that).
      #
      # This method accepts a hash of options, all of which are optional:
      # <tt>:subtype</tt>:: One of <tt>:invoice</tt>, <tt>:credit_note</tt> or <tt>:payment</tt>.
      # Also, the name of any +LedgerItem+ subclass method (as documented on the +LedgerItem+ module)
      # may be used, mapping it to the name which is actually used by the classes, to allow renaming.
      def acts_as_ledger_item(*args)
        Invoicing::ClassInfo.acts_as(Invoicing::LedgerItem, self, args)
        before_validation :calculate_total_amount
        
        # Set the 'amount' columns to act as currency values
        total_amount = ledger_item_class_info.method(:total_amount)
        tax_amount   = ledger_item_class_info.method(:tax_amount)
        currency     = ledger_item_class_info.method(:currency)
        acts_as_currency_value(total_amount, tax_amount, :currency => currency)        
      end
      
      # This callback is invoked when ActMethods has been mixed into ActiveRecord::Base.
      def self.extended(other) #:nodoc:
        Invoicing::LedgerItem::Base.acts_as_ledger_item
        Invoicing::LedgerItem::Invoice.acts_as_ledger_item    :subtype => :invoice
        Invoicing::LedgerItem::CreditNote.acts_as_ledger_item :subtype => :credit_note
        Invoicing::LedgerItem::Payment.acts_as_ledger_item    :subtype => :payment
      end
    end
    
    
    def calculate_total_amount
      # Calculate sum of net_amount and tax_amount across all line items, and assign it to total_amount;
      # calculate sum of tax_amount across all line items, and assign it to tax_amount.
    end
    
    
    # You must overwrite this method in subclasses of +Invoice+, +CreditNote+ and +Payment+ so that it returns
    # details of the party sending the document. See +sender_id+ above for a detailed interpretation of
    # sender and receiver.
    #
    # The methods +sender_details+ and +recipient_details+ are required to return hashes
    # containing details about the sender and recipient of an invoice, credit note or payment. The reason we
    # do this is that you probably already have your own system for handling users, customers and their personal
    # or business details, and this framework shouldn't require you to change any of that.
    #
    # The invoicing framework currently uses these details only for rendering invoices and credit notes, but
    # in future it may serve more advanced purposes, such as determining which tax rate to apply for overseas
    # customers.
    #
    # In the hash returned by +sender_details+ and +recipient_details+, the following keys are recognised --
    # please fill in as many as possible:
    # <tt>:is_self</tt>::      +true+ if these details refer to yourself, i.e. the person or organsiation who owns/operates
    #                          this application. +false+ if these details refer to any other party.
    # <tt>:name</tt>::         The name of the person or organisation whose billing address is defined below.
    # <tt>:contact_name</tt>:: The name of a person/department within the organisation named by <tt>:name</tt>.
    # <tt>:address</tt>::      The body of the billing address (not including city, postcode, state and country); may be
    #                          a multi-line string, with lines separated by '\n' line breaks.
    # <tt>:city</tt>::         The name of the city or town in the billing address.
    # <tt>:state</tt>::        The state/region/province/county of the billing address as appropriate.
    # <tt>:postal_code</tt>::  The postal code of the billing address (e.g. ZIP code in the US).
    # <tt>:country</tt>::      The billing address country (human-readable).
    # <tt>:country_code</tt>:: The two-letter country code of the billing address, according to
    #                          ISO-3166-1[http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2].
    # <tt>:vat_number</tt>::   The Value Added Tax registration code of this person or organisation, if they have
    #                          one, preferably including the country identifier at the beginning. This is important for
    #                          transactions within the European Union.
    def sender_details
      raise 'overwrite this method'
    end
    
    # You must overwrite this method in subclasses of +Invoice+, +CreditNote+ and +Payment+ so that it returns
    # details of the party receiving the document. See +recipient_id+ above for a detailed interpretation of
    # sender and receiver. See +sender_details+ for a list of fields to return in the hash.
    def recipient_details
      raise 'overwrite this method'
    end
    
    # Returns a boolean which specifies whether this transaction should be recorded as a debit (+true+)
    # or a credit (+false+) on a particular ledger. Unless you know what you are doing, you probably
    # do not need to touch this method.
    #
    # It takes an argument +self_id+, which should be equal to either +sender_id+ or +recipient_id+ of this
    # object, and which determines from which perspective the account is viewed. The default behaviour is:
    # * A sent invoice (<tt>self_id == sender_id</tt>) is a debit since it increases the recipient's liability;
    #   a sent credit note or a sent payment receipt is a credit because it decreases the recipient's
    #   liability.
    # * A received invoice (<tt>self_id == recipient_id</tt>) is a credit because it increases your own
    #   liability; a received credit note or a received payment receipt is a debit because it decreases
    #   your own liability.
    def is_debit?(self_id)
      sender_is_self = (sender_id == self_id) || (self_id.nil? && sender_details[:is_self])
      recipient_is_self = (recipient_id == self_id) || (self_id.nil? && recipient_details[:is_self])
      unless sender_is_self || recipient_is_self
        raise ArgumentError, "self_id #{self_id.inspect} is neither sender nor recipient"
      end
      if sender_is_self && recipient_is_self
        raise ArgumentError, "self_id #{self_id.inspect} is both sender and recipient"
      end
      
      if self.class.ledger_item_class_info.subtype == :invoice
        sender_is_self
      else
        recipient_is_self
      end
    end
    
    # Usually there is no need to derive classes directly from <tt>Invoicing::LedgerItem::Base</tt>.
    # Use <tt>Invoicing::LedgerItem::Invoice</tt>, <tt>Invoicing::LedgerItem::CreditNote</tt>
    # and <tt>Invoicing::LedgerItem::Payment</tt> instead.
    class Base < ::ActiveRecord::Base
      #acts_as_ledger_item
      
      def initialize(*args)
        super
        # Initialise uuid attribute if possible
        info = ledger_item_class_info
        if self.has_attribute?(info.method(:uuid)) && info.uuid_generator
          write_attribute(info.method(:uuid), info.uuid_generator.generate)
        end
      end
    end
    
    # Base class for all types of invoice in your application.
    class Invoice < Base
      #acts_as_ledger_item :subtype => :invoice
    end
    
    # Base class for all types of credit note in your application.
    class CreditNote < Base
      #acts_as_ledger_item :subtype => :credit_note
    end
    
    # Base class for all types of payment note in your application.
    # Please note that this class doesn't implement any particular means of payment (such as credit
    # card handling) -- the purpose of this class is to record the fact that a payment has taken
    # place, not to deal with the actual mechanics of it. However, if you want to add support for
    # credit card handling and implement it in a subclass of +Payment+, you're more than welcome,
    # of course.
    class Payment < Base
      #acts_as_ledger_item :subtype => :payment
    end


    # Stores state in the ActiveRecord class object
    class ClassInfo < Invoicing::ClassInfo::Base #:nodoc:
      attr_reader :subtype, :uuid_generator
      
      def initialize(model_class, previous_info, args)
        super
        @subtype = all_options[:subtype]
        
        @uuid_generator = nil
        begin # try to load the UUID gem
          require 'uuid'
          @uuid_generator = UUID.new
        rescue LoadError, NameError # silently ignore if gem not found
        end
      end
    end

  end # module LedgerItem
end
