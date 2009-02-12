---
title: Ruby Invoicing Framework Gem
layout: home
---

Ruby Invoicing Framework
========================

So... you've spent many nights developing your awesome application. It's coming
together nicely, and you've showed it to your friends, who got very excited about it
too. In fact, people love your app so much that they are willing to *pay you money*
to use it. Great news!

Keeping it simple, you start taking payments trough PayPal or even accept cheques
through the post. Later you maybe integrate with the API of a more flexible credit
card handling provider. Money is coming in -- even better news!

The problems become apparent when you try to turn your app into a business. Suddenly
everything becomes a lot more complicated. You need to start thinking about ugly
things like tax and you need to pay an accountant to sort out the paperwork for you.
You need to start bookkeeping, a prospect which gives you the shivers. Maybe some of
your customers are awkward, accepting billing only in their own currency or requiring
a special tax status. It's all a bit of a mess, and as you grudgingly start
ploughing through the Wikipedia page on "credits and debits", you wish that you
could just get the money and leave it at that.


The missing link between your app and the money
-----------------------------------------------

Enter the [Ruby Invoicing Framework RubyGem](http://ept.github.com/invoicing/),
or *invoicing gem* for short. It's a collection of tools which provide the basic
mechanisms for supporting financial transactions within your own application.

It aims to handle the most common cases neatly and concisely, but also provides
you with the flexibility to grow and handle pretty complex stuff when you need
it: multi-currency support, international taxation and reseller networks, for
example.

The invoicing gem is both developer-friendly and accountant-friendly: on the
surface you work with some fairly straightforward model objects, but inside it
is basically a full double-entry ledger accounting system. It provides the
information which your accountant needs to know, which means you can spend
less on accountants' fees when they fix up your business accounts at the end
of the year. But it also tries very hard to be friendly to you, the code artist,
so that you don't have to worry about the ugly financial stuff and you can get
on with making your app even more awesome.

The invoicing gem builds on ActiveRecord, which makes it perfectly suited for
use inside Rails web applications. It doesn't depend on the rest of Rails though,
so you should be able to use it in any Ruby application using a database.


What the invoicing gem is not
-----------------------------

* It is not a web-based invoicing application -- if you're a freelancer wanting
  to bill your hours to your clients, you should probably look elsewhere. The
  invoicing gem is intended for applications which need to bill their subscribers
  automatically and calculate charges internally.
* It is not an accounting/bookkeeping application -- there's no pretty front-end,
  no graphs. However, we want to integrate the invoicing gem with existing
  bookkeeping software, because they augment each other perfectly. If you can help
  us by connecting the invoicing gem to your accounting package of choice, please
  let us know.
* It does not currently implement any particular payment providers' APIs, although
  that's something we want to do eventually. At the moment, our focus is more on
  calculating things like tax, and providing a solid layer on which you can build
  your business logic.


Getting started
---------------

Sounds intriguing? Here's more:
* [Overview of the invoicing gem's main features](overview.html)
* [Getting started guide for using the invoicing gem in your application](getting_started.html)

Once you've familiarised yourself with the basics, you might want to start
[browsing the API documentation](http://invoicing.rubyforge.org/doc/) --
everything is documented very thoroughly there.

"I predict that @martinkl's "invoicing" gem will be considered essential when
it hits 1.0." -- @bensummers

News
----

{% for post in site.posts %}
* [{{ post.title }}](/invoicing{{ post.url }}) ({{ post.date | date_to_string }})
{% endfor %}

[Subscribe to our feed](http://feeds2.feedburner.com/invoicing) to keep up-to-date
with invoicing gem news!


Copyright
---------

The Ruby Invoicing Framework is developed by [Martin Kleppmann](http://www.yes-no-cancel.co.uk),
and development is sponsored by [Ept Computing](http://www.eptcomputing.com). It is
released under the terms of the MIT License.
