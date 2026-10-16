# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::WebExtension::ParamsParser do
  subject(:result) { described_class.new(params, worker).process }

  let(:worker) { Sidekiq::Enqueuer::Worker::Instance.new(WorkerWithOptionalParams, async: false) }

  context "with typed values" do
    let(:params) { { "required_param" => "42", "optional_param" => "1.5", "optional_param2" => "true" } }

    it { expect(result.args).to eq([42, 1.5, true]) }
  end

  context "with false, nil, JSON and quoted text" do
    let(:params) { { "required_param" => "false", "optional_param" => "nil", "optional_param2" => '[1, {"a": 2}]' } }

    it { expect(result.args).to eq([false, nil, [1, { "a" => 2 }]]) }
  end

  context "with text that only looks numeric" do
    let(:params) { { "required_param" => "024", "optional_param" => '"123"', "optional_param2" => "AR" } }

    it { expect(result.args).to eq(["024", "123", "AR"]) }
  end

  context "with trailing blanks" do
    let(:params) { { "required_param" => "x", "optional_param" => " ", "optional_param2" => "" } }

    it "leaves them out so method defaults apply" do
      expect(result.args).to eq(["x"])
    end
  end

  context "with a blank before a filled value" do
    let(:params) { { "required_param" => "x", "optional_param" => "", "optional_param2" => "y" } }

    it { expect(result.args).to eq(["x", nil, "y"]) }
  end

  context "with keyword params" do
    let(:worker) { Sidekiq::Enqueuer::Worker::Instance.new(JobWithKeywordParams, async: false) }
    let(:params) { { "country" => "AR", "max_created_at" => "", "dry_run" => "true" } }

    it "returns kwargs and leaves blank keywords out" do
      expect(result.args).to eq(["AR"])
      expect(result.kwargs).to eq(dry_run: true)
    end
  end

  context "with a missing required param" do
    let(:params) { { "required_param" => "" } }

    it { expect { result }.to raise_error(described_class::Error, "required_param is required") }
  end

  context "with invalid JSON" do
    let(:params) { { "required_param" => "[1," } }

    it { expect { result }.to raise_error(described_class::Error, /required_param is not valid JSON/) }
  end

  context "with non-hash params" do
    let(:worker) { Sidekiq::Enqueuer::Worker::Instance.new(NoParamWorker, async: false) }
    let(:params) { nil }

    it { expect(result.args).to eq([]) }
  end
end
