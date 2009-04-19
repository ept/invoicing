desc "Run tests in rcov to analyse code coverage"
task :coverage do
  exec "rcov -x '/Library/' -T test/*_test.rb"
end
