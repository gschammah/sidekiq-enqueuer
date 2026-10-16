# frozen_string_literal: true

require "simplecov"
require "simplecov-lcov"

SimpleCov::Formatter::LcovFormatter.config do |config|
  config.report_with_single_file = true
  config.output_directory = "coverage"
  config.lcov_file_name = "lcov.info"
end

SimpleCov.configure do
  enable_coverage :line
  enable_coverage :branch

  minimum_coverage line: 95, branch: 75

  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter,
  ])

  group "Worker", "/lib/enqueuer/worker"
  group "WebExtension", "/lib/enqueuer/web_extension"

  skip "/lib/sidekiq/enqueuer/views/"
  skip "/lib/sidekiq/enqueuer/locales/"
  skip "/spec/"
end
