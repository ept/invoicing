desc "Run rake test for invoicing gem"
task :test do
  exec "cd invoicing; rake test"
end

task :create_db do
  cmd_string = %[mysqladmin create ept_invoicing_test -u build]
  system cmd_string
end

def runcoderun?
  ENV["RUN_CODE_RUN"]
end

if runcoderun?
  task :default => [:create_db, :test]
else
  task :default => :test
end
