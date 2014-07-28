# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pglint/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Lukas Fittl"]
  gem.email         = ["team@pganalyze.com"]
  gem.description   = gem.summary = "PostgreSQL query analysis in development mode"
  gem.homepage      = "http://pglint.io"
  gem.license       = "MIT"

  gem.executables   = []
  gem.files         = `git ls-files | grep -Ev '^(examples)'`.split("\n")
  gem.test_files    = `git ls-files -- test/*`.split("\n")
  gem.name          = "pglint"
  gem.require_paths = ["lib"]
  gem.version       = Pglint::VERSION
  gem.add_dependency                  'json'
  gem.add_development_dependency      'sinatra'
end