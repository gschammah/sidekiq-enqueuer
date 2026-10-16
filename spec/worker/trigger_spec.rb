# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::Worker::Trigger do
  before { Timecop.freeze(Time.at(0)) }

  context "with a Sidekiq job" do
    it "enqueues to the job's queue and returns the jid" do
      jid = described_class.new(WorkerWithDefinedQueue, []).enqueue

      job = Sidekiq::Queue.new("custom_queue").first
      expect(job.klass).to eq("WorkerWithDefinedQueue")
      expect(job.jid).to eq(jid)
    end

    it "schedules with args" do
      jid = described_class.new(HardWorker, [1, "b"]).enqueue_in(120)

      job = Sidekiq::ScheduledSet.new.first
      expect([job.klass, job.args, job.at.to_i, job.jid]).to eq(["HardWorker", [1, "b"], 120, jid])
    end
  end

  context "with an ActiveJob" do
    it "enqueues with kwargs and returns the jid" do
      jid = described_class.new(JobWithKeywordParams, ["AR"], { dry_run: true }).enqueue

      job = Sidekiq::Queue.new("default").first
      expect(job.display_class).to eq("JobWithKeywordParams")
      expect(job.jid).to eq(jid)
      expect(job.args.first["arguments"]).to eq(["AR", { "dry_run" => true, "_aj_ruby2_keywords" => ["dry_run"] }])
    end

    it "schedules" do
      described_class.new(HardJob, ["a", "b"]).enqueue_in(60)

      expect(Sidekiq::ScheduledSet.new.first.at.to_i).to eq(60)
    end

    it "returns nil when enqueuing is aborted" do
      job_class = Class.new(HardJob) do
        def self.name = "AbortedJob"
        before_enqueue { throw :abort }
      end

      expect(described_class.new(job_class, ["a", "b"]).enqueue).to be_nil
      expect(Sidekiq::Queue.new("default").size).to eq(0)
    end
  end

  it "rejects other classes" do
    expect { described_class.new(String, []).enqueue }.to raise_error(described_class::UnsupportedJobType)
    expect { described_class.new(String, []).enqueue_in(1) }.to raise_error(described_class::UnsupportedJobType)
  end
end
