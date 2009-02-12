---
layout: default
title: Ruby Invoicing Gem version 0.1 released
---

Here it is, the first public release of the Ruby Invoicing Framework gem! In
case you don't know what it is, [check the website](http://ept.github.com/invoicing) --
in a nutshell, it is a bunch of tools and a structure which can be used inside
commercial (web) applications to handle billing of customers, tax calculations, and
other financial matters.

The core of the invoicing gem was born in mid-2008 while I was working on the Rails app
[Bid for Wine](http://www.bidforwine.co.uk/), an eBay-style auction site specifically
for wine, alongside Patrick Dietrich, Conrad Irwin and Michael Arnold. Our client
required a very flexible invoicing system for the site: not only should the site
be able to invoice sellers for listing fees and commissions, but sellers should also
be able to send invoices to their buyers, directly via the site. Some sellers are
VAT registered while others are not, which adds another dimension. What's more, due
to UK alcohol trade licensing legislation, some transactions must be handled with
Bid for Wine as intermediary -- i.e. the seller invoices Bid for Wine, and Bid for
Wine invoices the buyer. Add in-bond wine to the mix (wine on which duty has not yet
been paid -- it is stored in a special warehouse and the taxman gets his money when
you take it out of the warehouse), and you end up with a massively confusing array
of different transactions.

Natural, therefore, that we would build a system which was flexible and generalised
enough to cope with a wide variety of different transaction types.

Since [Bid for Wine launched in November 2008](http://www.yes-no-cancel.co.uk/2008/11/01/bid-for-wine-is-up-and-running/),
I have found myself wanting to use such a framework for financial transactions in
other applications too. I realised that even if you have a simple web app with, say,
a monthly subscription model, you will inevitably end up adding complexity over time:
for example, if you want to partner with resellers (and pay them a commission, or
invoice them at a preferential rate), if you want to trade in other currencies, and
of course you may have to implement whatever new tax regulations the political
forces may dream up.

I knew *nothing* about bookkeeping and accountancy until a year or so ago, when I
started doing the accounts for [my company](http://www.eptcomputing.com/). It was a
fairly painful process, because I am very much a developer and a computer scientist,
and the accountants' way of thinking first made no sense to me whatsoever. The
principles of [accrual accounting](http://en.wikipedia.org/wiki/Accounting_methods#Accrual_basis)
and [double-entry bookkeeping](http://en.wikipedia.org/wiki/Double-entry_bookkeeping_system)
are perfectly sensible and sound, but the terminology and practical implementation
I found just plain confusing.

After learning the basics of accounting, I still find it dead boring. And that is
really the reason why I took the Bid for Wine code in January 2009 and started
extracting a general-purpose finance handling framework out of it: I wanted to find
a neat representation of the data, one which made both me as a developer happy and 
also satisfied the accountants; and I wanted to package it up so that I wouldn't
have to think about the financial stuff any more than necessary: I wanted to make it
go away, not by ignoring it, but by automating it as much as possible, and by
explaining it in a way which doesn't require you to know any accounting jargon.

What I have now released, the *Invoicing gem version 0.1.0*, is the combination of all
the experience we gathered while developing Bid for Wine with several weeks of my
full-time work. Despite the young version number, this is already a pretty solid and
stable framework. I waited with the first release until I felt that the core API was
well enough thought out that I could minimize the number of backwards-incompatible
changes in the upcoming minor versions up to 1.0.

And even this very first public release is thoroughly documented and tested. In fact,
about half of the 3,300 lines of library code are actually documentation, and the
code has 100% [rcov](http://eigenclass.org/hiki/rcov) coverage through unit tests.
Databases currently supported are MySQL and PostgreSQL, and the gem depends on
ActiveRecord 2.1 or higher.

The [feature list](http://ept.github.com/invoicing/overview.html) includes a lot
of things which you know you ought to have, but you probably wouldn't bother
implementing yourself. For example, when we first developed Bid for Wine, the
VAT rate was set in a constant; however, within a month of launching, the UK
government decided to change the VAT rate (with one week's notice!), and I had
[a bit of a panic](http://search.twitter.com/search?q=vat+from%3Amartinkl) to
implement a tax rate change feature in our application. (It's not as simple as
changing the value of the constant, because the VAT applied to the price of an
auction is the rate applicable at a point in time in the future, namely the time
when the auction ends -- so you can have different items taxed at different
rates on the site simultaneously.)

Needless to say, the invoicing gem includes a feature for handling tax rate changes
neatly out of the box. And that was just an example. See the
[invoicing gem overview page](http://ept.github.com/invoicing/overview.html)
for a list of features.

Yesterday I met up with [Ben Summers](http://www.fluffy.co.uk/), who is using the
invoicing gem in his soon-to-be-launched online information management system
[OneIS](http://www.oneis.co.uk/). He is delighted at how much time it is saving him,
and at the future possibilities which the invoicing gem already offers now.

And I have plenty of plans for the future. But more on that another day.

Please help me spread the word, tag your tweets with `#invgem`,
[subscribe to the invoicing gem feed](http://feeds2.feedburner.com/invoicing),
[give the gem a try](http://ept.github.com/invoicing/getting_started.html), browse
[the docs](http://invoicing.rubyforge.org/doc/) and
[the source](http://github.com/ept/invoicing/), and
[let me know what you think](http://www.yes-no-cancel.co.uk/contact/)!

{% include martin.html %}
