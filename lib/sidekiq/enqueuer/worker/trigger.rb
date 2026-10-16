# frozen_string_literal: true

module Sidekiq
  module Enqueuer
    module Worker
      class Trigger
        class UnsupportedJobType < StandardError; end

        attr_reader :job, :queue, :args, :kwargs

        def initialize(job, args, kwargs = {})
          @job = job
          @queue = deduce_queue
          @args = args
          @kwargs = kwargs
        end

        def enqueue
          case
          when sidekiq_job?
            Sidekiq::Client.enqueue_to(queue, job, *args)
          when active_job?
            jid_of(job.perform_later(*args, **kwargs))
          else
            raise UnsupportedJobType, "Unsupported job type: #{job}"
          end
        end

        def enqueue_in(time_in_seconds)
          case
          when sidekiq_job?
            Sidekiq::Client.enqueue_to_in(queue, time_in_seconds, job, *args)
          when active_job?
            jid_of(job.set(wait: time_in_seconds).perform_later(*args, **kwargs))
          else
            raise UnsupportedJobType, "Unsupported job type: #{job}"
          end
        end

        private

        # perform_later returns false when enqueuing was aborted (e.g. a unique job
        # that is already queued).
        def jid_of(active_job)
          return unless active_job && active_job.successfully_enqueued? != false

          active_job.provider_job_id || active_job.job_id
        end

        def deduce_queue
          job.respond_to?(:get_sidekiq_options) ? job.get_sidekiq_options["queue"].to_s : "default"
        end

        def sidekiq_job?
          Sidekiq::Enqueuer::Utils.sidekiq_job?(job)
        end

        def active_job?
          Sidekiq::Enqueuer::Utils.active_job?(job)
        end
      end
    end
  end
end
