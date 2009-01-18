# This file is silently executed before the entire test suite runs, when run by 'rake test'.
# To see its output, set the environment variable VERBOSE=1

require File.join(File.dirname(__FILE__), "test_helper.rb")

connection = ActiveRecord::Base.connection

Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '*.sql')) do |filename|
  file = File.new(File.expand_path(filename))
  
  command = ''
  file.each do |line|
    unless line =~ /\A\s*--/ # ignore comments
      if line =~ /(.*);\s*\Z/ # cut off semicolons at the end of a command
        command += ' ' + $1
        connection.execute command
        puts command.strip
        command = ''
      else
        command += ' ' + line.strip
      end
    end
  end
end