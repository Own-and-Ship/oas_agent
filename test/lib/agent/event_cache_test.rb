# encoding: utf-8
# frozen_string_literal: true

require "test_helper"
require "agent/agent"

class OasAgentRubyEventCacheTest < Minitest::Test
  def test_starts_the_count_at_0
    event = OasAgent::Agent::EventCache.new("fakehash", "Some deprecation message", "Ruby", "version 1", ["a", "b"], "/some/root")
    assert_equal 0, event.for_serialization[OasAgent::Agent::EventCache::DATA_INDEXES[:counts]]
  end

  def test_events_can_be_incremented
    event = OasAgent::Agent::EventCache.new("fakehash", "Some deprecation message", "Ruby", "9000", ["a", "b"], "/some/root")
    10.times { event.increment }
    assert_equal 10, event.for_serialization[OasAgent::Agent::EventCache::DATA_INDEXES[:counts]]
  end

  def test_for_serialization
    event = OasAgent::Agent::EventCache.new("fakehash", "Some deprecation message", "Ruby", "9000", ["a", "b"], "/some/root")
    event.increment
    expected = ["fakehash", "Some deprecation message", "Ruby", ["a", "b"], "9000", "/some/root", 1 ]
    assert_equal expected, event.for_serialization
  end

  # Class methods

  def test_hash_for_event_data
    assert_equal "f2fa641a7c6d5beb6f7984678d95e06a1e057ae9e50b0c4eadd8c238942d506c", OasAgent::Agent::EventCache.hash_for_event_data("some message", "ruby", "1.2.3.4", ["a", "b", "c"], "/some/program/root")
  end
end
