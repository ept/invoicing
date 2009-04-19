desc "Run tests in rcov to analyse code coverage"
task :coverage do
  exec "rcov -x '/Library/' test/*_test.rb"
end
