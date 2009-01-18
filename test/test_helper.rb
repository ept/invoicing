require 'test/unit'
require 'rubygems'
require 'activerecord'
require 'activesupport'
require 'flexmock/test_unit'
require 'mocha'

$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'invoicing'

ActiveRecord::Base.establish_connection(
    :adapter  => "mysql",
    :host     => "localhost",
    :database => "invoicing_test",
    :username => "root",
    :password => ""
)


# Behave a bit like ActiveRecord's transactional fixtures.
module Test
  module Unit
    class TestCase
      def setup
        ActiveRecord::Base.connection.increment_open_transactions
        ActiveRecord::Base.connection.begin_db_transaction
      end
      
      def teardown
        ActiveRecord::Base.connection.rollback_db_transaction
        ActiveRecord::Base.connection.decrement_open_transactions
      end
    end
  end
end
