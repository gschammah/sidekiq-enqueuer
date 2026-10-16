# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::Configuration do
  describe "#jobs" do
    subject(:available_jobs) { config.available_jobs }

    let(:config) { described_class.new }

    context "with provided jobs" do
      before { config.jobs = %w[NoParamWorker HardWorker] }

      it { is_expected.to eq([HardWorker, NoParamWorker]) }

      context "with constants jobs" do
        before { config.jobs = [NoParamWorker, HardWorker] }

        it { is_expected.to eq([HardWorker, NoParamWorker]) }
      end

      context "with unsupported job class" do
        before { config.jobs = [123, 321] }

        it "raises corresponding error" do
          expect { available_jobs }.to raise_error(described_class::UnsupportedJobType)
        end
      end
    end

    context "without provided jobs" do
      # include, not match_array: other specs define job classes at runtime too.
      it "queries active job and sidekiq jobs" do
        expect(available_jobs).to include(*[
          NoParamWorker, HardWorker, HardJob, WorkerWithPerformAsync, WorkerWithNoParams,
          WorkerWithKeyValueParams, WorkerWithOptionalParams, WorkerWithDefinedQueue,
          JobWithKeywordParams, WorkerWithSplat
        ])
        expect(available_jobs).not_to include(ActiveJob::Base)
      end
    end

    context "with anonymous job classes loaded" do
      it "skips them instead of failing to sort" do
        anonymous = Class.new { include Sidekiq::Job }

        expect { available_jobs }.not_to raise_error
        expect(available_jobs).not_to include(anonymous)
      end
    end
  end
end
