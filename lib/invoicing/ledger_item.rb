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
  #   (until at some point you write it off as bad debt, but that's beyond our scope right now).
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
  # as you go along; while it is +open+ it is not technically an invoice, but only a statement
  # of accumulated charges. If you display it to users, make sure that you don't call it "invoice",
  # to avoid confusion. Only when you set it to +closed+ at the end of the month does the
  # statement become an invoice for legal purposes. Once it's +closed+, of course you mustn't add
  # any further charges to it.
  #
  # Finally, please only use positive numeric values on invoices, credit notes and payments (unless
  # you have been given other instructions by your accountant). Use the +sender_id+ and +recipient_id+
  # fields to indicate the direction of a transaction (see below).
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
  # them the same ActiveRecord table name (using <tt>ActiveRecord::Base#set_table_name</tt>). That
  # database table must have a certain minimum set of columns and a few common methods, documented
  # below (although you may rename any of them if you wish). Beyond those, you may add as many other
  # methods and database columns as you like to support the operation of your application, provided
  # they don't interfere with names used here.
  #
  # The following methods/database columns are <b>required</b> for +LedgerItem+ objects:
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
  #   about the party identified by +sender_id+. See below for the expected contents of the hash. Must always return
  #   valid details, even if +sender_id+ is +NULL+.
  #
  # +recipient_details+::
  #   A method (does not have to be a database column) which returns a hash with information
  #   about the party identified by +recipient_id+. See below for the expected contents of the hash. Must always
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
  #   A datetime column which indicates the date on which the document is issued, and which also
  #   serves as the tax point (the date which determines which tax rate is applied). This should be a separate
  #   column, because it won't necessarily be the same as +created_at+ or +updated_at+. There may be business
  #   reasons for choosing particular dates, but the date at which you send the invoice or receive the payment
  #   should do unless your accountant advises you otherwise.
  #
  # +currency+::
  #   The 3-letter code which identifies the currency used in this transaction; must be one of the list
  #   of codes in ISO-4217[http://en.wikipedia.org/wiki/ISO_4217]. (Even if you only use one currency throughout
  #   your site, this is needed to format amounts correctly.)
  #
  # +total_amount+::
  #   A decimal column containing the grand total monetary sum (of the invoice or credit note), or the monetary
  #   amount paid (of the payment record), including all taxes, charges etc. See the documentation of the
  #   +CurrencyRounding+ module for notes on choosing a suitable datatype for this column.
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
  # +tax_amount+::
  #   If you're a small business you maybe don't need to add tax to your invoices; but if you are successful,
  #   you almost certainly will need to do so eventually. In most countries this takes the form of Value Added
  #   Tax (VAT) or Sales Tax. Use this column to store the amount of tax contained on the invoice (this figure
  #   must be included in +total_amount+), so that you know how much of the payment value needs to go to the
  #   taxman. See the documentation of the +CurrencyRounding+ module for notes on suitable datatypes for
  #   monetary values.
  #
  # +uuid+::
  #   A Universally Unique Identifier (UUID)[http://en.wikipedia.org/wiki/UUID] string for this invoice, credit
  #   note or payment. It may seem unnecessary now, but may help you to keep track of your data later on as
  #   your system grows.
  #
  # +created_at+, +updated_at+::
  #   The standard ActiveRecord datetime columns for recording when an object was created and last changed.
  #   The values are not directly used at the moment, but it's useful information in case you need to track down
  #   a particular transaction sometime; and ActiveRecord manages them for you anyway.
  module LedgerItem
    
    module ActMethods
      # Declares that the current class is a model for ledger items (i.e. invoices, credit notes and
      # payment notes). It is recommended that instead of using +acts_as_ledger_item+, you make your
      # invoice, credit note and payment classes subclasses of <tt>Invoicing::LedgerItem::Invoice</tt>,
      # <tt>Invoicing::LedgerItem::CreditNote</tt> and <tt>Invoicing::LedgerItem::Payment</tt> instead.
      # Use +acts_as_ledger_item+ only if you do not want to change your existing class hierarchy
      # (which may be the case if you are retrofitting this invoicing gem to your existing application).
      #
      # This method accepts a hash of options, all of which are optional:
      # * +subtype+ - One of <tt>:invoice</tt>, <tt>:credit_note</tt> or <tt>:payment</tt>.
      def acts_as_ledger_item(options={})
        
      end
    end
    
    module InvoiceMethods
      
    end
    
    module CreditNoteMethods
      
    end
    
    module PaymentMethods
      
    end
    
    # sender/recipient details:
    # is_self?
    def sender_details
      raise 'overwrite this method'
    end
    
    def is_debit?
      raise 'overwrite this method'
    end
    
    def is_visible?
      true
    end
    
    # Usually there is no need to derive classes directly from <tt>Invoicing::LedgerItem::Base</tt>.
    # Use <tt>Invoicing::LedgerItem::Invoice</tt>, <tt>Invoicing::LedgerItem::CreditNote</tt>
    # and <tt>Invoicing::LedgerItem::Payment</tt> instead.
    class Base < ::ActiveRecord::Base
      #acts_as_ledger_item
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
    
    
  end
end