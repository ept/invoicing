Developing the invoicing gem
============================

You need to set up a test database, using something like (for MySQL, the default):

    $ echo "create database ept_invoicing_test" | mysql -uroot

    $ echo "grant all on ept_invoicing_test.* to 'build'@'%'" | mysql -uroot

Then run the tests by typing `rake`.

FIXME: add notes on Postgres, testing different gem versions, testing different Ruby versions, ...
