begin
  require 'securerandom'
rescue
  require 'active_support/secure_random'
end

require 'pglint/atomic_output'

ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |name, started, finished, unique_id, data|
  next unless Rails.env.development?
  Pglint::CurrentReport.start(data[:path], Rails.root.join("tmp/pglint"))
end

ActiveSupport::Notifications.subscribe "sql.active_record" do |name, started, finished, unique_id, data|
  next unless Pglint::CurrentReport.active?
  duration = finished - started
  next if data[:name] == "CACHE"
  Pglint::CurrentReport.add_query({sql: data[:sql], duration_ms: duration * 1000})
end

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  next unless Pglint::CurrentReport.active?
  Pglint::CurrentReport.finish(duration_db_ms: data[:db_runtime].to_f, duration_view_ms: data[:view_runtime].to_f)
end