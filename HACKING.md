Developing the invoicing gem
============================

For development, you need up-to-date versions of the following gems (`sudo gem install <gemname>`):

  * rake
  * activerecord
  * mysql (if you use MySQL)
  * pg (if you use PostgreSQL)
  * newgem
  * flexmock

Fork the invoicing gem on GitHub, then clone it to your machine:

    $ git clone git@github.com:YOUR-GITHUB-USERNAME/invoicing.git


MySQL
-----

You need to set up a test database. You can modify the settings for the test database in
`config/database.yml`, but if you stick with the defaults, you can set up the database like this:

    $ echo "create database ept_invoicing_test" | mysql -uroot
    $ echo "grant all on ept_invoicing_test.* to 'build'@'%'" | mysql -uroot

Then run the tests by typing `rake`.


PostgreSQL
----------

To set up the test database, run something like the following as root:

    # su -c 'createuser -SDRP invoicing' postgres  # (enter "password" as password)
    # su -c 'createdb -O invoicing invoicing_test' postgres

Then run the tests by typing:

    $ DATABASE=postgresql rake
