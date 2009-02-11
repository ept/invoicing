---
title: Ruby Invoicing Framework
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
your customers are awkward, accepting billing only in their own currency or reqiring
a special tax status. It's all a bit of a mess, and as you grudgingly start
ploughing through the Wikipedia page on "credits and debits", you wish that you
could just get the money and leave it at that.


The missing link between your app and the money
-----------------------------------------------

The Ruby invoicing framework provides tools, helpers and a structure for
applications (particularly web apps) which need to generate invoices for
customers. It builds on ActiveRecord and is particularly suited for Rails
applications, but could be used with other frameworks too.


What it is not
--------------

News
----

{% for post in site.posts %}
* [{{ post.title }}](/invoicing{{ post.url }}) ({{ post.date | date_to_string }})
{% endfor %}

Dependencies
------------

ActiveRecord >= 2.1

Install
-------

{% highlight console %}
$ sudo gem install invoicing
{% endhighlight %}

You can also clone the project with [Git](http://git-scm.com) by running:

{% highlight console %}
$ git clone git://github.com/ept/invoicing
{% endhighlight %}

Or [view the source code on GitHub](http://github.com/ept/invoicing).

Usage
-----

{% highlight ruby %}
class LedgerItem < ActiveRecord::Base
  acts_as_ledger_item
end
{% endhighlight %}


License
-------

MIT License

Author
------

[Martin Kleppmann](http://github.com/ept)

