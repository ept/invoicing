require File.join(File.dirname(__FILE__), 'test_helper.rb')

class ConnectionAdapterExtTest < Test::Unit::TestCase

  # Don't run these tests in database transactions.
  def setup
  end
  def teardown
  end
  

  def test_conditional_function_as_mysql
    begin
      ActiveRecord::Base.establish_connection(TEST_DB_CONFIG[:mysql])
      assert_equal "IF(true, foo, bar)", Invoicing::ConnectionAdapterExt.conditional_function('true', 'foo', 'bar')
    ensure
      connect_to_testing_database
    end
  end

  def test_conditional_function_as_postgresql
    begin
      ActiveRecord::Base.establish_connection(TEST_DB_CONFIG[:postgresql])
      assert_equal "CASE WHEN true THEN foo ELSE bar END", Invoicing::ConnectionAdapterExt.conditional_function('true', 'foo', 'bar')
    ensure
      connect_to_testing_database
    end
  end

  def test_conditional_function_as_sqlite
    begin
      ActiveRecord::Base.establish_connection(TEST_DB_CONFIG[:sqlite3])
      assert_raise RuntimeError do
        Invoicing::ConnectionAdapterExt.conditional_function('true', 'foo', 'bar')
      end
    ensure
      connect_to_testing_database
    end
  end

end