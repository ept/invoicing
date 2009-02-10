---
title: Ruby Invoicing Framework
layout: default
---

Ruby Invoicing Framework
========================

The Ruby invoicing framework provides tools, helpers and a structure for
applications (particularly web apps) which need to generate invoices for
customers. It builds on ActiveRecord and is particularly suited for Rails
applications, but could be used with other frameworks too.

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
{% endhighlight}

You can also clone the project with [Git](http://git-scm.com) by running:

{% highlight console %}
$ git clone git://github.com/ept/invoicing
{% endhighlight}

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

