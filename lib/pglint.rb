# encoding: utf-8

require 'pglint/version'
require 'pglint/dbinfo'
require 'pglint/current_report'

if defined?(::Rails)
  require 'pglint/rails'
  require 'pglint/report'
  require 'pglint/rspec' if defined?(::RSpec) && Rails.env.test?
end