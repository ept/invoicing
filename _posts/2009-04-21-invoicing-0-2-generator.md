---
layout: default
title: Ruby Invoicing Gem version 0.2 — Now with generator
---

Yesterday was a busy day: in the morning I released the new version 0.2 of the invoicing
gem, and in the evening I presented a live demo of the latest version at the
[London Ruby User Group](http://lrug.org/meetings/2009/03/23/april-2009-meeting/).

The format of my talk was an attempt to replicate a screencast, but given completely
live. The result was pretty hilarious, and I hope there will be a video recording of it
online eventually.

Since I didn't have any slides for the talk I will simply share the notes which I wrote for
myself in preparation. You might be able to use them to follow along with what I was doing.


About the invoicing gem
-----------------------

* Commercial app: start with paypal; gets complicated soon -- VAT, resellers/affiliates, ...
* You don't parse HTTP headers yourself; you shouldn't need to juggle credits+debits yourself
* Developer friendly AND accountant-friendly

Roadmap:
* v0.1: get basics right (core ledger, multi-currency, time-dependent values)
* v0.2: `script/generate invoicing_ledger` -- render ledger/statement/invoice
* v0.3: `script/generate invoicing_taxable` -- support European VAT out of the box
* v0.4: higher-level tools (subscriptions, price plans, affiliate programmes)


Cracktastic preparation
-----------------------

[Cracktastic](http://github.com/ept/cracktastic) is a simple and contrived example Rails app
into which we want to integrate the invoicing gem. Check out the head of the `master` branch.
Start with a clean database and run `rake db:migrate`.


Set up ledger
-------------

Invoke generator:

    script/generate invoicing_ledger billing --currency=GBP
    rake db:migrate

Manually edit `app/models/billing/ledger_item.rb`:

{% highlight ruby %}
belongs_to :sender, :class_name => 'Company'
belongs_to :recipient, :class_name => 'Company'

def sender_details
  sender.attributes.symbolize_keys
end

def recipient_details
  recipient.attributes.symbolize_keys
end
{% endhighlight %}


Create custom invoice type
--------------------------

Add new model classes:

{% highlight ruby %}
module Billing
  class SubscriptionInvoice < Invoice
    def initialize(*args)
      super
      self.status ||= 'open'
      self.period_start ||= Time.now.utc.at_beginning_of_month
      self.period_end ||= period_start.next_month.at_beginning_of_month
      self.issue_date ||= period_end
      self.due_date ||= period_end + 14.days
      self.description ||= "Cracktastic subscription for " +
        period_start.strftime('%B %Y')
    end
  end
end

module Billing
  class MonthlySubscriptionCharge < LineItem
    before_validation :calculate_tax

    def initialize(*args)
      super
      self.tax_point ||= Time.now.utc
      self.description ||= "Monthly subscription, standard package"
    end

    def calculate_tax
      self.tax_amount = 0.15*net_amount
    end
  end
end
{% endhighlight %}


Integrate with `restful_authentication`
---------------------------------------

Edit generated `billing_controller.rb`:

{% highlight ruby %}
before_filter :login_required

def index
  redirect_to ledger_url(current_user.company)
end
    
def ledger
  raise ActiveRecord::RecordNotFound unless current_user.company_id.to_s == params[:id]
  #...
end

def statement
  raise ActiveRecord::RecordNotFound unless current_user.company_id.to_s == params[:id]
  #...
end

def document
  @ledger_item = Billing::LedgerItem.sent_or_received_by(current_user.company_id).find(params[:id])
  #...
end
{% endhighlight %}

Add to main menu in `app/views/layouts/application.html.erb`:

{% highlight erb %}
<% if logged_in? -%>
  <li><%= link_to 'Billing', ledger_path(current_user.company) %></li>
<% end -%>
{% endhighlight %}


Create example records
----------------------

Open up `script/console`:

{% highlight ruby %}
ourselves = Company.find(1)
customer = Company.find(2)

# Closed invoice for last month
inv = Billing::SubscriptionInvoice.new(
  :period_start => Time.now.utc.last_month.at_beginning_of_month)
inv.sender = ourselves
inv.recipient = customer
inv.line_items << Billing::MonthlySubscriptionCharge.new(:net_amount => 99.95)
inv.save!
inv.status = 'closed'
inv.save!

# Payment for last month
pay = Billing::Payment.new :total_amount => 114.94, :status => 'cleared', 
  :description => 'Credit card payment', :issue_date => 3.days.ago.utc
pay.sender = ourselves
pay.recipient = customer
pay.save!

# Open invoice for current month
inv = Billing::SubscriptionInvoice.new
inv.sender = ourselves
inv.recipient = customer
inv.line_items << Billing::MonthlySubscriptionCharge.new(:net_amount => 99.95)
inv.save!
{% endhighlight %}

Then reload the mongrel and open `/billing` in the app to see the results.


Credit notes
------------

{% highlight ruby %}
ourselves = Company.find(1)
customer = Company.find(2)

note = Billing::CreditNote.new(
  :period_start => Time.now.utc.last_month.at_beginning_of_month,
  :period_end => Time.now.utc.at_beginning_of_month,
  :issue_date => Time.now.utc,
  :description => 'Refund', :status => 'closed')
note.sender = ourselves
note.recipient = customer
note.line_items << Billing::MonthlySubscriptionCharge.new(
  :net_amount => -50, :description => 'Special half-price offer')
note.save!
{% endhighlight %}

Note the negative amount on the line item.


CurrencyValue magic
-------------------

In `script/console`:

{% highlight ruby %}
inv = Billing::Invoice.new :currency => 'USD'
line = Billing::LineItem.new :net_amount => 12.34
inv.line_items << line
inv.save!

line.net_amount.to_s
# => "12.34"
line.net_amount_formatted
# => "$12.34"
line.tax_amount = 0.15 * line.net_amount
# => 1.851
line.tax_amount.to_s
# => "1.85"         <==== automatically rounded to 0.01 precision
line.tax_amount_formatted
# => "$1.85"

inv.currency = 'JPY' # Smallest currency unit in Japanese yen is 1
line.net_amount_formatted :symbol => 'JPY'
# => "12 JPY"       <==== automatically rounded to integer
line.tax_amount_formatted :symbol => 'JPY'
# => "2 JPY"
{% endhighlight %}

You can also leave away the `:symbol => 'JPY'` bit, in which case it will be rendered as
"¥12" and "¥2" respectively.


Multi-currency support
----------------------

In `script/console`:

{% highlight ruby %}
ourselves = Company.find(1)
customer = Company.find(2)

inv = Billing::SubscriptionInvoice.new(
  :currency => 'JPY', :status => 'closed', :description => 'Commission charges')
inv.sender = customer
inv.recipient = ourselves
inv.line_items << Billing::MonthlySubscriptionCharge.new(
  :net_amount => 23, :description => 'Referral commission')
inv.save!
{% endhighlight %}

See the results in a web browser. Also demonstrates `customer` charging `ourselves`,
i.e. acting as supplier to us.


UBL support
-----------

Append `.xml` to the URL of an invoice document.


Automatic tax calculation
-------------------------

*NOTE:* This is a feature from the upcoming 0.3 release of the gem. It will not work with the
version currently released to Rubyforge.

Run the generator:

    script/generate invoicing_taxable UK
    rake db:migrate

In file `app/models/billing/line_item.rb`, add:

{% highlight ruby %}
belongs_to :tax_rate
acts_as_taxable :net_amount, :tax_logic => Invoicing::Countries::UK::VAT.new

def initialize(*args)
  super
  self.tax_point ||= Time.now.utc      
  self.tax_rate ||= TaxRate.default_record_at(tax_point)
end
{% endhighlight %}

From `app/models/billing/monthly_subscription_charge.rb`, remove the `calculate_tax` stuff.

In `script/console`:

{% highlight ruby %}
ourselves = Company.find(1)
customer = Company.find(2)

inv = Billing::SubscriptionInvoice.new :period_start => '2008-11-01', :status => 'closed'
inv.sender = ourselves
inv.recipient = customer
nov = Billing::LineItem.new(:description => 'random 1',
  :net_amount => 10, :tax_point => '2008-11-30')
dec = Billing::LineItem.new(:description => 'random 2',
  :net_amount => 10, :tax_point => '2008-12-01')
inv.line_items << nov
inv.line_items << dec
inv.save!

nov.amount_formatted
# => "10.00"
nov.amount_taxed_formatted
# => "11.75"
nov.amount_with_tax_info
# => "11.75 (inc. VAT)"
nov.amount_with_tax_details
# => "11.75 (including VAT at 17.5%)"
dec.amount_formatted
# => "10.00"
dec.amount_taxed_formatted
# => "11.50"
dec.amount_with_tax_info
# => "11.50 (inc. VAT)"
dec.amount_with_tax_details
# => "11.50 (including VAT at 15%)"
{% endhighlight %}


And that's it
-------------

Open `/thankyou` in web browser to show my contact details on the projector.

If you're thinking of using the invoicing gem, or have any questions, or want to submit
patches, or anything... [let me know](http://www.yes-no-cancel.co.uk/contact/)!

Please help me spread the word, tag your tweets with `#invgem`,
[subscribe to the invoicing gem feed](http://feeds2.feedburner.com/invoicing),
[give the gem a try](http://ept.github.com/invoicing/getting_started.html), browse
[the docs](http://invoicing.rubyforge.org/doc/) and
[the source](http://github.com/ept/invoicing/), and
[let me know what you think](http://www.yes-no-cancel.co.uk/contact/)!

{% include martin.html %}
