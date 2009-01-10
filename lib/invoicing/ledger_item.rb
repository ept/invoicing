module Invoicing
  # == Ledger item objects
  #
  # This module implements a simple ledger, i.e. the record of all of the business transactions
  # which are handled by your application. Each transaction is recorded as one +LedgerItem+ object,
  # each of which may have one of the following three types:
  #
  # * +Invoice+ - When you send an invoice to someone (= a customer), this is a record of the fact
  #   that you have sold them something (a product, a service etc.), and how much you expect to be
  #   paid for it. An invoice can consist of a list of individual charges, but it is considered as
  #   one document for legal purposes. You can also create invoices from someone else to yourself,
  #   if you owe someone else money -- for example, if you need to pay commissions to a reseller of
  #   your application.
  # * +CreditNote+ - This is basically an invoice with negative value; you should use it if you have
  #   previously sent a customer an invoice with an amount which was too great
  #
  # == Important principles
  #
  # Note the distinction between Invoices/Credit Notes and Payments; to keep your accounts clean,
  # it is important that you do not muddle these up.
  #
  # * <b>Invoices and Credit Notes</b> are the important documents for tax purposes in most
  #   jurisdictions. They record the date on which the sale is officially made, and that date
  #   determines which tax rates apply. An invoice also represents the transfer of ownership from
  #   the supplier to the customer; for example, if you ask your customers to send payment in
  #   advance (such as 'topping up' their account), that money still belongs to your customer
  #   until the point where they have used your service, and you have charged them for your
  #   service by sending them an invoice. 
  # * <b>Payments</b> are just what it says on the tin -- the transfer of money from one hand
  #   to another. A payment may occur before an invoice is issued (payment in advance), or
  #   after/at the same time as an invoice is issued to settle the debt (payment in arrears, giving
  #   your customers credit). You can choose whatever makes sense for your business.
  #   Payments may often be associated one-to-one with invoices, but not necessarily -- an invoice
  #   may be paid in instalments, or several invoices may be lumped together to one payment. Your
  #   customer may even refuse to pay some charges, in which case there is an invoice but no payment.
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
  # == Using invoices, credit notes and payments in your application
  #
  # All invoices, credit notes and payments (collectively called 'ledger items') are stored in a
  # single database table. We use <b>single table inheritance</b> to distinguish the object types:
  # this module provides a base class type <tt>Invoicing::LedgerItem::Base < ActiveRecord::Base</tt>
  # and three subclasses:
  # * <tt>Invoicing::LedgerItem::Invoice</tt> - base class for all types of invoice,
  # * <tt>Invoicing::LedgerItem::CreditNote</tt> - base class for all types of credit note, and
  # * <tt>Invoicing::LedgerItem::Payment</tt> - base class for all types of payment.
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
  # Ledger methods:
  #
  # identifier          # Assigned by the creditor/supplier
  # type                # For single table inheritance
  # status              # Invoices: open, closed, cancelled; Payment: pending, cleared, failed
  # issue_date          # = tax point
  # currency            # 3 letter code
  # total_amount        # including all taxes and charges
  # sender_id           # for grouping
  # sender_details      # Invoice/CN: supplier; Payment: payee
  # recipient_id        # for grouping
  # recipient_details   # Invoice/CN: buyer; Payment: payer
  # is_debit?           # false => is credit
  # is_visible?         # visible to user?
  # note/description
  #
  #
  # optional ledger methods:
  #
  # uuid
  # period_start
  # period_end
  # tax_amount
  # created_at
  # updated_at
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
    
    
    # Usually there is no need to derive classes directly from <tt>Invoicing::LedgerItem::Base</tt>.
    # Use <tt>Invoicing::LedgerItem::Invoice</tt>, <tt>Invoicing::LedgerItem::CreditNote</tt>
    # and <tt>Invoicing::LedgerItem::Payment</tt> instead.
    class Base < ::ActiveRecord::Base
      acts_as_ledger_item
    end
    
    # Base class for all types of invoice in your application.
    class Invoice < Base
      acts_as_ledger_item :subtype => :invoice
    end
    
    # Base class for all types of credit note in your application.
    class CreditNote < Base
      acts_as_ledger_item :subtype => :credit_note
    end
    
    # Base class for all types of payment note in your application.
    class Payment < Base
      acts_as_ledger_item :subtype => :payment
    end
    
    
  end
end