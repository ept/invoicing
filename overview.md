---
title: Overview
layout: default
---

What can it do?

* Store any number of different types of invoice, credit note and payment record
* Represent customer accounts, supplier accounts, and even complicated multi-party
  billing relationships
* Automatically format currency values beautifully
* Automatically round currency values to the customary precision for that particular
  currency, e.g. based on the smallest coin in circulation
* Support any number of different currencies simultaneously
* Render invoices, account statements etc. into HTML (fully styleable and
  internationalisable)
* Export into the [UBL XML format](http://ubl.xml.org/) for sharing data with other
  systems
* Provide you with a default Value Added Tax (VAT) implementation, but you can
  also easily plug in your own tax logic
* Dynamically display tax-inclusive or tax-exclusive prices depending on your
  customer's location and preferences
* Deal with tax rates or prices changing over time, and automatically switch to the
  new rate at the right moment
* Efficiently summarise account balances, sales statements etc. under arbitrary
  conditions (e.g. data from one quarter, or payments due at a particular date).


The Ruby Invoicing Framework Gem is stable and solid:

* Thorough test coverage -- RCov reports 100% code coverage (I'll take that with
  a pinch of salt, but it's a good start)
* It is being put into production use in several applications
* Compatible with PostgreSQL and MySQL
* Economical in its use of database queries


Stuff you need to do yourself
-----------------------------

To begin with, it should be sufficient if you create the necessary database tables
and model classes, as described in [Getting Started](getting_started.html), and
then write a few lines of business logic. For example, you might create a script
which you run on the first day of each month, which invoices all of your customers
for their use of your application during that month. It would look something like
this:

{% highlight ruby %}
Customers.all.each do |customer|
  invoice = Invoice.new(
    :recipient_id => customer.id,
    :currency => customer.price_plan.currency,
    :status => 'closed',
    :period_start => Time.now,
    :period_end => 1.month.from_now,
    :due_date => 14.days.from_now
  )
  
  invoice.line_items << MonthlySubscriptionCharge.new(
    :net_amount => customer.price_plan.price_now
  )
  
  invoice.save!
end
{% endhighlight %}

Simple! No need to say more than necessary. The amount of tax and the sum of the
invoice are calculated automatically.

Of course, your site doesn't need to use a monthly subscription model -- a
pay-by-use model or a pay-once purchase model can be used just as easily. And of
course you can mix different types of charges and different types of invoice
as you please.

Displaying invoices to your customers is even easier. In a Rails application,
for example, you might have a controller action a bit like the following:

{% highlight ruby %}
class BillingController < ApplicationController

  def invoice
    invoice = Invoice.find(params[:id])

    unless invoice.customer_id == current_user.customer_id
      raise ActiveRecord::RecordNotFound, "Access denied"
    end

    respond_to do |format|
      format.html { render :layout => true, :text => invoice.render_html }
      format.xml  { render :xml => invoice.render_ubl }
    end
  end
end
{% endhighlight %}

And that's it! You don't even need a template, as the `render_html` method
already lays it out nicely for you. (You can use it in a template if you prefer,
and you can arbitrarily customise the output of `render_html`.) And you get
interoperability for free via the
[OASIS UBL standard](http://www.oasis-open.org/committees/ubl/).

Of course there is a lot more to to discover. Read
[Getting Started](getting_started.html) to get the basics set up, and then you
can start reading the [API documentation](http://invoicing.rubyforge.org/doc/)
to get the in-depth details.
