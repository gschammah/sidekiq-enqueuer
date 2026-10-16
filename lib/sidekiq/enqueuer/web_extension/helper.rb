# frozen_string_literal: true

module Sidekiq
  module Enqueuer
    module WebExtension
      module Helper
        def find_job_by_class_name(job_class_name)
          return if job_class_name.nil? || job_class_name.empty?

          Sidekiq::Enqueuer.jobs.find { |job| job.name == job_class_name }
        end

        def describe_args(parsed)
          parts = parsed.args.map(&:inspect) + parsed.kwargs.map { |key, value| "#{key}: #{value.inspect}" }
          parts.empty? ? "no arguments" : "(#{parts.join(", ")})"
        end
      end
    end
  end
end
