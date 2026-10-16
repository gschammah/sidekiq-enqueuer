# frozen_string_literal: true

module Sidekiq
  module Enqueuer
    module WebExtension
      module Loader
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.registered(app)
          app.helpers(WebExtension::Helper)

          view_path = File.join(File.expand_path("..", __dir__), "views")

          app.get "/enqueuer" do
            @jobs = Sidekiq::Enqueuer.jobs

            render(:erb, File.read(File.join(view_path, "index.erb")))
          end

          app.get "/enqueuer/:job_class_name" do
            @job = find_job_by_class_name(route_params(:job_class_name))
            halt(404) unless @job

            @error = @job.unsupported_reason
            @values = {}
            render(:erb, File.read(File.join(view_path, "new.erb")))
          end

          app.post "/enqueuer" do
            @job = find_job_by_class_name(url_params("job_class_name"))
            halt(404) unless @job

            submit = url_params("submit")
            @values = url_params("perform").is_a?(Hash) ? url_params("perform") : {}
            @enqueue_in = url_params("enqueue_in").to_s.strip

            begin
              raise ParamsParser::Error, @job.unsupported_reason if @job.unsupported_reason

              parsed = ParamsParser.new(@values, @job).process

              jid =
                case submit
                when "Enqueue"
                  @job.trigger(parsed)
                when "Schedule"
                  unless @enqueue_in.match?(/\A[1-9]\d*\z/)
                    raise ParamsParser::Error, "Enqueue in must be a whole number of seconds greater than 0"
                  end

                  @job.trigger_in(@enqueue_in.to_i, parsed)
                else
                  raise ParamsParser::Error, "Unknown action: #{submit}"
                end
            rescue ParamsParser::Error => e
              @error = e.message
              next render(:erb, File.read(File.join(view_path, "new.erb")))
            end

            if jid
              when_text = submit == "Schedule" ? " to run in #{@enqueue_in}s" : ""
              flash { h("#{@job.name} enqueued#{when_text} with #{describe_args(parsed)} (jid #{jid})") }
            else
              flash { h("#{@job.name} was not enqueued. It may be a unique job that is already queued.") }
            end

            redirect File.join(root_path, "enqueuer")
          end
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end
