begin
  require File.dirname(__FILE__) + '/test_helper'
rescue LoadError
  require 'test/unit'
end
require 'fileutils'

# Load generator libs in the form needed for generating a new rails project
gem 'rails'
require 'rails/version'
require 'rails_generator'
require 'rails_generator/scripts/generate'

# Configure the path of the temporary rails project in which our component
# generators will be run in tests.
TMP_ROOT = File.dirname(__FILE__) + "/tmp" unless defined?(TMP_ROOT)
PROJECT_NAME = "myproject" unless defined?(PROJECT_NAME)
app_root = File.join(TMP_ROOT, PROJECT_NAME)
if defined?(APP_ROOT)
  APP_ROOT.replace(app_root)
else
  APP_ROOT = app_root
end
# if defined?(RAILS_ROOT)
#   RAILS_ROOT.replace(app_root)
# else
#   RAILS_ROOT = app_root
# end

begin
  require 'rubigen'
rescue LoadError
  require 'rubygems'
  require 'rubigen'
end
require 'rubigen/helpers/generator_test_helper'
