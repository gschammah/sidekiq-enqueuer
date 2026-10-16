# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::WebExtension::Loader do
  include_context "web extension api context"

  before do
    Sidekiq::Enqueuer.configure do |config|
      config.jobs = %w[NoParamWorker HardWorker HardJob JobWithKeywordParams WorkerWithKeyValueParams]
    end
  end

  describe "GET /enqueuer" do
    it "shows the tab and lists jobs with their params" do
      get "/enqueuer"

      expect(last_response).to be_successful
      expect(last_response.body).to include("Enqueuer", "HardWorker", "param1, param2")
      expect(last_response.body).to include("country, max_created_at:, dry_run:")
    end
  end

  describe "GET /enqueuer/:job_class_name" do
    it "shows the form" do
      get "/enqueuer/HardJob"

      expect(last_response).to be_successful
      expect(last_response.body).to include("Enqueue HardJob", 'name="perform[param1]"')
    end

    it "warns about jobs it cannot enqueue" do
      get "/enqueuer/WorkerWithKeyValueParams"

      expect(last_response.body).to include('<p class="error">', "Sidekiq cannot pass")
    end

    it "returns 404 for unknown jobs" do
      get "/enqueuer/Nope"

      expect(last_response.status).to eq(404)
    end
  end

  describe "POST /enqueuer" do
    it "enqueues a Sidekiq job with typed args" do
      post_form("HardWorker", perform: { "param1" => "v1", "param2" => "2" })

      expect(last_response).to be_redirect
      job = Sidekiq::Queue.new.first
      expect([job.klass, job.args]).to eq(["HardWorker", ["v1", 2]])
      expect(flash_message).to match(/HardWorker enqueued with \(&quot;v1&quot;, 2\) \(jid \h+\)/)
    end

    it "enqueues an ActiveJob with kwargs" do
      post_form("JobWithKeywordParams", perform: { "country" => "AR", "dry_run" => "true" })

      expect(Sidekiq::Queue.new.first.display_class).to eq("JobWithKeywordParams")
      expect(flash_message).to include("JobWithKeywordParams enqueued with (&quot;AR&quot;, dry_run: true)")
    end

    it "schedules a job" do
      Timecop.freeze(Time.at(0))
      post_form("HardJob", perform: { "param1" => "a", "param2" => "b" }, submit: "Schedule", enqueue_in: "120")

      expect(Sidekiq::ScheduledSet.new.first.at.to_i).to eq(120)
      expect(flash_message).to include("HardJob enqueued to run in 120s")
    end

    it "re-renders the form with the error and the input" do
      post_form("HardWorker", perform: { "param1" => "", "param2" => "keep me" })

      expect(last_response).to be_successful
      expect(last_response.body).to include('<p class="error">param1 is required</p>', 'value="keep me"')
      expect(Sidekiq::Queue.new.size).to eq(0)
    end

    it "requires a positive delay to schedule" do
      post_form("NoParamWorker", submit: "Schedule", enqueue_in: "")

      expect(last_response.body).to include("whole number of seconds greater than 0")
      expect(Sidekiq::ScheduledSet.new.size).to eq(0)
    end

    it "rejects unknown actions" do
      post_form("NoParamWorker", submit: "Explode")

      expect(last_response.body).to include("Unknown action: Explode")
    end

    it "refuses jobs it cannot enqueue" do
      post_form("WorkerWithKeyValueParams", perform: { "required_param" => "x" })

      expect(last_response.body).to include("Sidekiq cannot pass")
      expect(Sidekiq::Queue.new.size).to eq(0)
    end

    it "says when a job was not enqueued" do
      allow(Sidekiq::Client).to receive(:enqueue_to).and_return(nil)
      post_form("NoParamWorker")

      expect(flash_message).to include("NoParamWorker was not enqueued")
    end

    it "escapes input in the flash" do
      post_form("HardWorker", perform: { "param1" => "<script>", "param2" => "x" })

      flash = flash_message
      expect(flash).to include("&lt;script&gt;")
      expect(flash).not_to include("<script>")
    end

    it "returns 404 for unknown jobs" do
      post "/enqueuer", "authenticity_token" => csrf_token, "job_class_name" => "Nope"

      expect(last_response.status).to eq(404)
    end
  end
end
