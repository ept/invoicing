require File.join(File.dirname(__FILE__), 'test_helper.rb')

class CachedRecordTest < Test::Unit::TestCase
  
    
  class Record < ActiveRecord::Base
    
#    acts_as_cached_record
#    
#    def test_records
#      [
#        Record.new(:id => 1)
#      ]
#    end
#    
#    # Overwrite 'find(:all)' to return the list of test records to populate cache
#    def find_with_mock(*args)
#      (args == [:all]) ? test_records : find_without_mock(*args)
#    end
#    alias_method_chain :find, :mock
  end
  
  
  def test_should_foo
    ActiveRecord::Base.connection.execute "insert into cached_records () values()"
#    r = Record.new
#    r.save!
#    assert_equal(r.id, 1)
  end
  
end
