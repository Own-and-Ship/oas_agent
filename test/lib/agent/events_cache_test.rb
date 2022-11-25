# encoding: utf-8
# frozen_string_literal: true

require "test_helper"
require "agent/agent"

class OasAgentRubyEventsCacheTest < Minitest::Test
  def deserialize_event_cache(event_data)
    MessagePack.unpack(
      Zlib::Inflate.inflate(
        Base64.decode64(event_data)
      )
    )
  end

  def test_maintains_a_count_of_similar_events
    event_cache = OasAgent::Agent::EventsCache.new(program_root: "/some/root")
    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"])
    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"])
    assert_equal 2, deserialize_event_cache(event_cache.serializable).first[OasAgent::Agent::EventCache::DATA_INDEXES[:counts]]
  end

  def test_counts_separate_software_versions_separately
    event_cache = OasAgent::Agent::EventsCache.new(program_root: "/some/root")
    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"])
    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"])

    event_cache.add_event("Some deprecation message", "Ruby", "9001", ["a", "b"])

    assert_equal 2, deserialize_event_cache(event_cache.serializable).first[OasAgent::Agent::EventCache::DATA_INDEXES[:counts]]
    assert_equal 1, deserialize_event_cache(event_cache.serializable).last[OasAgent::Agent::EventCache::DATA_INDEXES[:counts]]
  end

  def test_maintains_separate_counts_of_distinct_events
    event_cache = OasAgent::Agent::EventsCache.new(program_root: "/some/root")
    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"])
    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"])

    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "c"])
    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "c"])

    event_cache.add_event("Some deprecation message", "Ruby", "9001", ["a", "b"])
    event_cache.add_event("Some deprecation message", "Ruby", "9001", ["a", "b"])

    event_cache.add_event("Other deprecation message", "Ruby", "9001", ["a", "b"])
    event_cache.add_event("Other deprecation message", "Ruby", "9001", ["a", "b"])

    event_cache.add_event("Some deprecation message", "Rails", "9001", ["a", "b"])
    event_cache.add_event("Some deprecation message", "Rails", "9001", ["a", "b"])

    assert_equal 2, deserialize_event_cache(event_cache.serializable)[0][OasAgent::Agent::EventCache::DATA_INDEXES[:counts]]
    assert_equal 2, deserialize_event_cache(event_cache.serializable)[1][OasAgent::Agent::EventCache::DATA_INDEXES[:counts]]
    assert_equal 2, deserialize_event_cache(event_cache.serializable)[2][OasAgent::Agent::EventCache::DATA_INDEXES[:counts]]
    assert_equal 2, deserialize_event_cache(event_cache.serializable)[3][OasAgent::Agent::EventCache::DATA_INDEXES[:counts]]
    assert_equal 2, deserialize_event_cache(event_cache.serializable)[4][OasAgent::Agent::EventCache::DATA_INDEXES[:counts]]
  end

  def test_it_knows_the_number_of_events_it_contains
    event_cache = OasAgent::Agent::EventsCache.new(program_root: "/some/root")
    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"])
    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "b"])

    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "c"])
    event_cache.add_event("Some deprecation message", "Ruby", "9000", ["a", "c"])

    assert_equal 2, event_cache.num_events
  end
end
