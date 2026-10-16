# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::Worker::Instance do
  def instance(job) = described_class.new(job, async: false)

  it "deduces perform params" do
    expect(instance(HardWorker).params.map { |p| [p.name, p.kind] }).to eq([[:param1, :req], [:param2, :req]])
    expect(instance(HardWorker).instance_method).to eq(:perform)
    expect(instance(WorkerWithPerformAsync).instance_method).to eq(:perform_async)
    expect(instance(NoParamWorker).params).to be_empty
  end

  it "has no unsupported reason for plain jobs" do
    expect(instance(HardWorker).unsupported_reason).to be_nil
    expect(instance(JobWithKeywordParams).unsupported_reason).to be_nil
  end

  it "refuses Sidekiq jobs with keyword params" do
    expect(instance(WorkerWithKeyValueParams).unsupported_reason).to include("Sidekiq cannot pass")
  end

  it "refuses splats" do
    expect(instance(WorkerWithSplat).unsupported_reason).to include("cannot fill")
  end

  it "uses the class name" do
    expect(instance(HardJob).name).to eq("HardJob")
  end
end
