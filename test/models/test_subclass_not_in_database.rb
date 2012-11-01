# Please do not require this file or the class name TestSubclassNotInDatabase
# anywhere. The whole point of it is that it is a subclass of TestBaseclass
# which exists, but is never loaded, because it isn't mentioned anywhere.
# FindSubclassesTest#test_known_subclasses tests this.
class TestSubclassNotInDatabase < TestBaseclass
end
