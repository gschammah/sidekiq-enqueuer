# frozen_string_literal: true

module Sidekiq
  module Enqueuer
    module Worker
      class Instance
        attr_reader :job, :instance_method, :params, :async

        def initialize(job, async:)
          @job = job
          @async = async
          @instance_method = deduce_instance_method
          @params = deduce_params
        end

        # @return [String, nil] the jid, or nil when the job was not enqueued
        def trigger(parsed)
          trigger_job(parsed).enqueue
        end

        # @return [String, nil] the jid, or nil when the job was not enqueued
        def trigger_in(seconds, parsed)
          trigger_job(parsed).enqueue_in(seconds)
        end

        def name
          @job.name
        end

        # Sidekiq serializes args as a JSON array, so it cannot pass keywords.
        def unsupported_reason
          if params.any? { |param| !param.supported? }
            "#{name}#perform takes *args, **kwargs or a block, which the enqueuer cannot fill"
          elsif Utils.sidekiq_job?(job) && params.any?(&:keyword?)
            "#{name} is a Sidekiq job with keyword arguments, which Sidekiq cannot pass"
          end
        end

        private

        def trigger_job(parsed)
          Sidekiq::Enqueuer::Worker::Trigger.new(job, parsed.args, parsed.kwargs)
        end

        def deduce_instance_method
          [:perform, :perform_in, :perform_async, :perform_at].each do |evaluating_method|
            return evaluating_method if job.instance_methods.include?(evaluating_method)
          end
          nil
        end

        def deduce_params
          return [] if instance_method.nil?

          job.instance_method(instance_method).parameters.map do |kind, name|
            Sidekiq::Enqueuer::Worker::Param.new(name, kind)
          end
        end
      end
    end
  end
end
