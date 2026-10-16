# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "sidekiq/enqueuer/version"

Gem::Specification.new do |spec|
  spec.name = "sidekiq-enqueuer"
  spec.version = Sidekiq::Enqueuer::VERSION
  spec.required_ruby_version = ">= 3.2"

  spec.authors = %w[richfisher basherru]
  spec.email = %w[richfisher.pan@gmail.com basherru@umbrellio.biz]
  spec.homepage = "https://github.com/gschammah/sidekiq-enqueuer"
  spec.licenses = ["MIT"]

  spec.summary = <<-SUMMARY
    A Sidekiq Web extension to enqueue/schedule jobs with custom perform params in Web UI.
  SUMMARY
  spec.description = <<-DESCRIPTION
    A Sidekiq Web extension to enqueue/schedule jobs with custom perform params in Web UI.
    Support both Sidekiq::Job and ActiveJob. Fork of umbrellio/sidekiq-enqueuer for Sidekiq 8.
  DESCRIPTION

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", ">= 8.0", "< 9"

  spec.add_development_dependency "activejob", ">= 7.0"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rack-session"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-lcov"
  spec.add_development_dependency "timecop"
end
