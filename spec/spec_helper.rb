# frozen_string_literal: true

require_relative "./setup_simplecov"

SimpleCov.start

# Sidekiq::Web reads its locale files with the default encoding.
Encoding.default_external = Encoding::UTF_8

require "bundler/setup"
require "active_job"
require "rack/session"
require "rack/test"
require "sidekiq"
require "sidekiq/api"
require "sidekiq/web"
require "sidekiq/enqueuer"
require "timecop"

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/15") }
end
Sidekiq.logger.level = Logger::ERROR

ActiveJob::Base.queue_adapter = :sidekiq
ActiveJob::Base.logger = Logger.new(nil)

Dir["#{__dir__}/support/**/*.rb"].sort.each { |x| require x }

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before { Sidekiq.redis(&:flushdb) }
  config.after { Timecop.return }
end
