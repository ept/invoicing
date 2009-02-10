# This file is silently executed before the entire test suite runs, when run by 'rake test'.
# To see its output, set the environment variable VERBOSE=1

require File.join(File.dirname(__FILE__), "test_helper.rb")

connection = ActiveRecord::Base.connection

Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '*.sql')) do |filename|
  file = File.new(File.expand_path(filename))
  
  command = ''
  file.each do |line|
  
    # Hacks to make fixture loading work with postgres. Very very ugly. Sorry :-(
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      line.gsub!(/datetime/, 'timestamp')
      line.gsub!(/tinyint\(1\)/, 'boolean')
      line.gsub!(/0(\).) \-\- false/, 'false\1')
      line.gsub!(/1(\).) \-\- true/, 'true\1')
      line.gsub!(/int primary key auto_increment/, 'serial')
      line.gsub!(/ENGINE=.*;/, ';')
    end
    
    line.gsub!(/\-\-.*/, '') # ignore comments
    
    if line =~ /(.*);\s*\Z/ # cut off semicolons at the end of a command
      command += ' ' + $1
      puts command.strip
      connection.execute command
      command = ''
    else
      command += ' ' + line.strip
    end
  end
end