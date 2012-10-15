# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "invoicing/version"

Gem::Specification.new do |s|
  s.name        = "invoicing"
  s.version     = Invoicing::VERSION.dup
  s.platform    = Gem::Platform::RUBY  
  s.summary     = "Ruby Invoicing Framework"
  s.email       = "ept@rubyforge.org"
  s.homepage    = "http://ept.github.com/invoicing/"
  s.description = "This is a framework for generating and displaying invoices (ideal for commercial Rails apps). It allows for flexible business logic; provides tools for tax handling, commission calculation etc. It aims to be both developer-friendly and accountant-friendly."
  s.authors     = ['Patrick Dietrich', 'Conrad Irwin', 'Michael Arnold', 'Martin Kleppmann']

  s.rubyforge_project = "invoicing"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end