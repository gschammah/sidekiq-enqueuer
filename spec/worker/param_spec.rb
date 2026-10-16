# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::Worker::Param do
  it "describes positional params" do
    required = described_class.new(:a, :req)
    optional = described_class.new(:b, :opt)

    expect([required.label, required.required?, required.keyword?]).to eq(["required", true, false])
    expect([optional.label, optional.optional?, optional.keyword?]).to eq(["optional", true, false])
  end

  it "describes keyword params" do
    required = described_class.new(:a, :keyreq)
    optional = described_class.new(:b, :key)

    expect([required.label, required.required?, required.keyword?]).to eq(["required keyword", true, true])
    expect([optional.label, optional.required?, optional.keyword?]).to eq(["optional keyword", false, true])
  end

  it "flags splats as unsupported" do
    expect(described_class.new(:args, :rest)).not_to be_supported
    expect(described_class.new(:a, :req)).to be_supported
  end
end
