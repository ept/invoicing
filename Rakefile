require 'rubygems'
require 'rake'
require 'rake/clean'
require 'fileutils'
require 'rake/testtask'

# Tasks to run by default
task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.warning = false
end
