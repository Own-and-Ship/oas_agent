# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::Agent::EventsCache do
  describe "#add_event" do
    context "with a new event" do
      it "adds it to the cache"
    end

    context "with an existing event" do
      it "increments the existing event count"
    end
  end

  describe "#num_events" do
    it "returns the number of events in the cache"
  end

  describe "#serializable" do
    it "returns a serialized version of the cache for transport"
  end
end
