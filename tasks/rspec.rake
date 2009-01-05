namespace :test do

  task :default => :spec

  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new do |r| 
    r.libs        = %w[ lib ] 
    r.spec_files  = FileList["spec/**/*.rb", "test/**/*.rb"] 
    r.spec_opts   = %w[ --format specdoc --color ]
    r.rcov        = true
    r.rcov_dir    = 'test-coverage'
    r.rcov_opts   = %w[ --html ]
  end
end
