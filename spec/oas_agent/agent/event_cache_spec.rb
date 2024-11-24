# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::Agent::EventCache do
  let(:event_data) { ["fakehash", "Some deprecation message", "Ruby", "version 1", ["a.rb", "b.rb"], "/some/root"] }

  subject(:event_cache) { described_class.new(*event_data) }

  describe ".hash_for_event_data" do
    subject(:result) { described_class.hash_for_event_data(*event_data[1..-1]) }

    it "returns a hash" do
      expect(result).to be_a(String)
      expect(result.length).to eq(64)
    end
  end

  describe "#new" do
    it "starts counting at zero" do
      expect(event_count).to eq(0)
    end
  end

  describe "#increment" do
    subject(:increment) { event_cache.increment }

    it "increments the count by 1" do
      expect{ increment }.to change{ event_count }.by(1)
    end
  end

  describe "#for_serialization" do
    let(:stored_data) do
      # For some reason we reverse these from method args to stored
      # API expects them in this order, so output is correct
      event_data.insert(3, event_data.delete_at(4))
      event_data + [0]
    end

    it "returns the event data as an array" do
      expect(event_cache.for_serialization).to eq(stored_data)
    end
  end

  def event_count
    event_cache.instance_variable_get(:@event_data)[described_class::DATA_INDEXES[:counts]]
  end
end
