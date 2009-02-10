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
* [{{ post.title }}]({{ post.url }}) ({{ post.date | date_to_string }})
{% endfor %}

Dependencies
------------

ActiveRecord >= 2.1

Install
-------

    $ sudo gem install invoicing

You can also clone the project with Git(http://git-scm.com) by running:

    $ git clone git://github.com/ept/invoicing

Or [view the source code on GitHub](http://github.com/ept/invoicing).

License
-------

MIT License

Author
------

[Martin Kleppmann](http://github.com/ept)

