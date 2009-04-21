---
title: Getting Started
layout: default
---

Start by installing the `invoicing` and `invoicing_generator` gems in the usual way:

{% highlight bash %}
sudo gem install invoicing invoicing_generator
{% endhighlight %}

(`invoicing_generator` is only needed for development; you don't need to install it on
your production servers.)

You can also clone the project with [Git](http://git-scm.com) by running:

{% highlight bash %}
git clone git://github.com/ept/invoicing
{% endhighlight %}

Or [view the source code on GitHub](http://github.com/ept/invoicing).


Run the generator
-----------------

New in Invoicing version 0.2: We now have a Rails generator which will set up the necessary
model objects, a database migration, and an example controller with views for displaying
the ledger, account statements, invoices and credit notes. To invoke the generator, go to
the root of your Rails project and type (replacing `GBP` with your default currency of
choice):

{% highlight bash %}
./script/generate invoicing_ledger billing --currency=GBP
{% endhighlight %}

The generator will do everything on this page (and more) for you automatically, so you can
skip the rest of this page. If you're using this gem in a non-Rails Ruby project, you'll
have to make the following changes manually.


Manual setup: Create the database tables
----------------------------------------

Now you need to create a few database tables. The following migration will get
you started. (It's currently focussed on a UK based, VAT registered business,
but we will soon generalise it internationally. You can also change any of the
names if you so please -- check the [API docs](http://invoicing.rubyforge.org/doc/)
for details.)

{% highlight ruby %}
class InvoicingTables < ActiveRecord::Migration
  def self.up
    create_table :ledger_items do |t|
      t.string :type
      t.integer :sender_id
      t.integer :recipient_id
      t.datetime :issue_date
      t.decimal :total_amount, :precision => 20, :scale => 4
      t.decimal :tax_amount, :precision => 20, :scale => 4
      t.string :currency, :null => false, :limit => 3
      t.text :status, :null => false, :limit => 12
      t.datetime :period_start
      t.datetime :period_end
      t.datetime :due_date
      t.timestamps
    end
    
    create_table :tax_rates do |t|
      t.datetime :valid_from, :null => false
      t.datetime :valid_until
      t.integer :replaced_by_id
      t.decimal :factor, :precision => 6, :scale => 6
      t.boolean :is_default
    end
    
    execute "INSERT INTO tax_rates (valid_from, factor, is_default) " +
      "VALUES('2008-12-01', 0.15, 1)"
    
    create_table :line_items do |t|
      t.string :type
      t.references :ledger_item, :null => false
      t.references :tax_rate
      t.decimal :net_amount, :precision => 20, :scale => 4
      t.decimal :tax_amount, :precision => 20, :scale => 4
      t.decimal :quantity, :precision => 10, :scale => 2
    end
  end
  
  def self.down
    drop_table :line_items
    drop_table :tax_rates
    drop_table :ledger_items
  end
end
{% endhighlight %}


Manual setup: Require the invoicing gem
---------------------------------------

Then tell your application that it should use the invoicing gem. For example,
in a Rails project, create a file called `config/initializers/invoicing.rb` with
the following contents:

{% highlight ruby %}
require 'invoicing'
{% endhighlight %}


Manual setup: Create model classes
----------------------------------

Next, create model classes corresponding to the tables above. Ideally, each should
live in its own file with a name based on its class name, as per the convention.

{% highlight ruby %}
class LedgerItem < ActiveRecord::Base
  acts_as_ledger_item
  has_many :line_items
end

class Invoice < LedgerItem
  acts_as_ledger_item :subtype => :invoice
end

class CreditNote < LedgerItem
  acts_as_ledger_item :subtype => :credit_note
end

class Payment < LedgerItem
  acts_as_ledger_item :subtype => :payment
end

class LineItem < ActiveRecord::Base
  acts_as_line_item
  belongs_to :ledger_item
  belongs_to :tax_rate
end

class TaxRate < ActiveRecord::Base
  acts_as_tax_rate :value => :factor
end
{% endhighlight %}


`LedgerItem` and `LineItem` both use single table inheritance. You are encouraged
to define a hierarchy of subclasses starting with `Invoice`, `CreditNote`, `Payment`
and `LineItem` which corresponds to the kinds of transactions you usually deal with.
For example:

{% highlight ruby %}
class CustomerMonthlyInvoice < Invoice
end

class ConsultancyInvoice < Invoice
end

class MonthlySubscriptionCharge < LineItem
end

class AdditionalStorageCharge < LineItem
end

class ApplicationSupportCharge < LineItem
end
{% endhighlight %}


Get rocking
-----------

And that's all you should need initially! You should now be able to write your
business logic as outlined in the [overview document](overview.html). For details,
please read the extensive [API docs](http://invoicing.rubyforge.org/doc/).

Also make sure you
[subscribe to our news feed](http://feeds2.feedburner.com/invoicing)
so that you hear about new features when they are released!
