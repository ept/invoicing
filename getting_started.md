---
title: Getting Started
layout: default
---

{% highlight bash %}
sudo gem install invoicing
{% endhighlight %}

You can also clone the project with [Git](http://git-scm.com) by running:

{% highlight bash %}
git clone git://github.com/ept/invoicing
{% endhighlight %}

Or [view the source code on GitHub](http://github.com/ept/invoicing).

Usage
-----

{% highlight ruby %}
class LedgerItem < ActiveRecord::Base
  acts_as_ledger_item
end
{% endhighlight %}

Dependencies
------------

ActiveRecord >= 2.1
