require File.join(File.dirname(__FILE__), 'test_helper.rb')

# Primary hierarchy of classes for testing.

class TestBaseclass < ActiveRecord::Base
  set_table_name 'find_subclasses_records'
  set_inheritance_column 'type_name' # usually left as default 'type'. rename to test renaming
  named_scope :with_coolness, lambda{|factor| {:conditions => {:coolness_factor => factor}}}
  include Invoicing::FindSubclasses
  def self.coolness_factor; 3; end
end

class TestSubclass < TestBaseclass

end

class TestSubSubclass < TestSubclass
  def self.coolness_factor; 5; end
end

module TestModule
  class TestInsideModuleSubclass < TestBaseclass
    def self.coolness_factor; nil; end
  end
end

class TestOutsideModuleSubSubclass < TestModule::TestInsideModuleSubclass
  def self.coolness_factor; 999; end
end


# This class' table contains non-existent subclass names, to test errors

class SomeSillySuperclass < ActiveRecord::Base
  include Invoicing::FindSubclasses
  set_table_name 'find_subclasses_non_existent'
end


#####################

class FindSubclassesTest < Test::Unit::TestCase
  
  def test_known_subclasses
    # All subclasses of TestBaseclass except for TestSubclassNotInDatabase
    expected = ['TestBaseclass', 'TestModule::TestInsideModuleSubclass', 'TestOutsideModuleSubSubclass',
      'TestSubSubclass', 'TestSubclass', 'TestSubclassInAnotherFile']
    assert_equal expected, TestBaseclass.known_subclasses.map{|cls| cls.name}.sort
  end
  
  def test_error_when_unknown_type_is_encountered
    assert_raise ActiveRecord::SubclassNotFound do
      SomeSillySuperclass.known_subclasses
    end
  end
  
  def test_find
    assert_equal [1, 2, 4], TestBaseclass.all(:conditions => {:coolness_factor => 3}).map{|r| r.id}.sort
  end
  
  def test_find2
    assert_equal [4], TestBaseclass.with_coolness(3).all(:conditions => ['id > 3']).map{|r| r.id}
  end
end
