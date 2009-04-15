require File.join(File.dirname(__FILE__), 'test_helper.rb')

class ConnectionAdapterExtTest < Test::Unit::TestCase

  # Don't run these tests in database transactions.
  def setup
  end
  def teardown
  end
  
  def using_database(database_type)
    begin
      ActiveRecord::Base.establish_connection(TEST_DB_CONFIG[database_type.to_sym])
      yield
    ensure
      connect_to_testing_database
    end
  end  

  def test_conditional_function_as_mysql
    using_database :mysql do
      assert_equal "IF(true, foo, bar)", Invoicing::ConnectionAdapterExt.conditional_function('true', 'foo', 'bar')
    end
  end

  def test_conditional_function_as_postgresql
    using_database :postgresql do
      assert_equal "CASE WHEN true THEN foo ELSE bar END",
        Invoicing::ConnectionAdapterExt.conditional_function('true', 'foo', 'bar')
    end
  end

  def test_conditional_function_as_sqlite3
    using_database :sqlite3 do
      assert_raise RuntimeError do
        Invoicing::ConnectionAdapterExt.conditional_function('true', 'foo', 'bar')
      end
    end
  end

  def test_group_by_all_columns_as_mysql
    using_database :mysql do
      assert_equal "`ledger_item_records`.`id2`",
        Invoicing::ConnectionAdapterExt.group_by_all_columns(MyLedgerItem)
    end
  end

  def test_group_by_all_columns_as_postgresql
    using_database :postgresql do
      assert_equal(
        '"ledger_item_records"."id2", "ledger_item_records"."type2", "ledger_item_records"."sender_id2", ' +
        '"ledger_item_records"."recipient_id2", "ledger_item_records"."identifier2", ' +
        '"ledger_item_records"."issue_date2", "ledger_item_records"."currency2", ' +
        '"ledger_item_records"."total_amount2", "ledger_item_records"."tax_amount2", ' +
        '"ledger_item_records"."status2", "ledger_item_records"."period_start2", ' +
        '"ledger_item_records"."period_end2", "ledger_item_records"."uuid2", ' +
        '"ledger_item_records"."due_date2", "ledger_item_records"."created_at", ' +
        '"ledger_item_records"."updated_at"',
        Invoicing::ConnectionAdapterExt.group_by_all_columns(MyLedgerItem))
    end
  end

  def test_group_by_all_columns_as_sqlite3
    using_database :sqlite3 do
      assert_raise RuntimeError do
        Invoicing::ConnectionAdapterExt.group_by_all_columns(MyLedgerItem)
      end
    end
  end

end