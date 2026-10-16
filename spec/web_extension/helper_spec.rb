# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::WebExtension::Helper do
  let(:helper) { Class.new { include Sidekiq::Enqueuer::WebExtension::Helper }.new }

  before { Sidekiq::Enqueuer.configure { |config| config.jobs = %w[NoParamWorker HardWorker] } }

  describe "#find_job_by_class_name" do
    it "finds configured jobs by name" do
      expect(helper.find_job_by_class_name("HardWorker").name).to eq("HardWorker")
    end

    it "returns nil for unknown or blank names" do
      expect(helper.find_job_by_class_name("TestingWorker")).to be_nil
      expect(helper.find_job_by_class_name("")).to be_nil
      expect(helper.find_job_by_class_name(nil)).to be_nil
    end
  end

  describe "#describe_args" do
    def parsed(args, kwargs = {}) = Sidekiq::Enqueuer::WebExtension::ParamsParser::Result.new(args, kwargs)

    it { expect(helper.describe_args(parsed([]))).to eq("no arguments") }
    it { expect(helper.describe_args(parsed(["AR", 1], { dry_run: true }))).to eq('("AR", 1, dry_run: true)') }
  end
end
