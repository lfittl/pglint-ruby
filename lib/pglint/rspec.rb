# Auto-create a report for every test run and output the URL at the end (for text formatter)

require 'pglint/threaded_send'

require 'rspec/core'
require 'rspec/core/formatters/base_text_formatter'

module Pglint
  report_send_thread = nil
end

class RSpec::Core::Formatters::BaseTextFormatter
  alias_method :orig_dump_summary, :dump_summary
  def dump_summary(duration, example_count, failure_count, pending_count)
    orig_dump_summary(duration, example_count, failure_count, pending_count)
    
    if Pglint::ThreadedSend.active?
      output.print "\npglint SQL Performance Report... "
      url = Pglint::ThreadedSend.result
      if url
        output.puts url
      else
        output.puts "Failed, check logs."
      end
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    begin
      Pglint::CurrentReport.start($0, Rails.root.join("tmp/pglint"))
    rescue => e
      Rails.logger.info "Failed to start pganalyze report: %s" % e
    end
  end
  
  config.after(:suite) do
    begin
      filename = Pglint::CurrentReport.finish
      Pglint::ThreadedSend.start!(filename)
    rescue => e
      Rails.logger.info "Failed to generate pganalyze report: %s" % e
    end
  end
end