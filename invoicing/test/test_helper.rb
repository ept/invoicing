require 'test/unit'
require 'rubygems'
require 'activerecord'
require 'activesupport'
require 'flexmock/test_unit'
require 'mocha'

$: << File.join(File.dirname(__FILE__), '..', 'lib')

ActiveSupport::Dependencies.load_paths << File.join(File.dirname(__FILE__), 'models')

require 'invoicing'

TEST_DB_CONFIG = {
  :postgresql => {:adapter => "postgresql", :host => "localhost", :database => "invoicing_test",
    :username => "postgres", :password => ""},
  :mysql => {:adapter => "mysql", :host => "localhost", :database => "invoicing_test",
    :username => "root", :password => ""}
}

def connect_to_testing_database
  ActiveRecord::Base.establish_connection(TEST_DB_CONFIG[(ENV['DATABASE'] || :mysql).to_sym])
end

connect_to_testing_database

ENV['TZ'] = 'Etc/UTC' # timezone of values in database
ActiveRecord::Base.default_timezone = :utc # timezone of created_at and updated_at
Time.zone = 'Etc/UTC' # timezone for output (when using Time#in_time_zone)


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
