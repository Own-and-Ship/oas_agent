# encoding: utf-8
# frozen_string_literal: true

require "spec_helper"
require "oas_agent/agent"

RSpec.describe OasAgent::Agent::EventsCache do
  let(:event_cache) { described_class.new("/some/root") }
  let(:event_cache_data) { deserialize_event_cache(event_cache.serializable) }

  describe "#add_event" do
    it "maintains a count of similar events" do
      event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"])
      event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"])

      expect(event_cache_data.first[OasAgent::Agent::EventCache::DATA_INDEXES[:counts]]).to eq(2)
    end

    it "counts separate software versions separately" do
      2.times do
        event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"])
      end
      event_cache.add_event("Some deprecation message", "Ruby", "9001", ["a", "b"])

      count_data = event_cache_data.map { |event| event[OasAgent::Agent::EventCache::DATA_INDEXES[:counts]] }
      expect(count_data).to match_array([2, 1])
    end

    it "maintains separate counts of distinct events" do
      # Add five different events, that have happened 1, 2, 3, etc times
      1.times { event_cache.add_event("First!!!1oneine1!!", "Ruby", "9000", ["a", "b"]) }
      2.times { event_cache.add_event("Second@@222@two@@2", "Ruby", "9000", ["a", "c"]) }
      3.times { event_cache.add_event("Third£££3three£££3", "Ruby", "9001", ["a", "b"]) }
      4.times { event_cache.add_event("Fourth$$4$four4$44", "Ruby", "9001", ["a", "b"]) }
      5.times { event_cache.add_event("Fifth%%5%five%5%55", "Rails", "9001", ["a", "b"]) }

      expect(event_cache_data).to match_array([
        array_including("First!!!1oneine1!!", 1),
        array_including("Second@@222@two@@2", 2),
        array_including("Third£££3three£££3", 3),
        array_including("Fourth$$4$four4$44", 4),
        array_including("Fifth%%5%five%5%55", 5),
      ])
    end
  end

  describe "#num_events" do
    it "knows the number of distinct events it contains" do
      2.times { event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"]) }
      3.times { event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "c"]) }

      expect(event_cache.num_events).to eq(2)
    end
  end

  describe "#serializable" do
    subject { event_cache.serializable }

    let(:event_1) { ["Some deprecation message", "Ruby", "9000", ["a", "b"]] }
    let(:event_2) { ["Other thing that'll break", "Ruby", "9001", ["a", "c"]] }

    before do
      event_cache.add_event(*event_1)
      event_cache.add_event(*event_2)
    end

    it "returns a string" do
      expect(subject).to be_a(String)
    end

    it "is deserializable" do
      expect(deserialize_event_cache(subject)).to match_array([array_including(*event_1), array_including(*event_2)])
    end
  end

  private

  def deserialize_event_cache(event_data)
    MessagePack.unpack(
      Zlib::Inflate.inflate(
        Base64.decode64(event_data)
      )
    )
  end
end
