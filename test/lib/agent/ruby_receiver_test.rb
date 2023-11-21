# frozen_string_literal: true

require "test_helper"
require "agent/agent"

class OasAgentRubyReceiverTest < Minitest::Test
  def test_strips_location_from_kwargs_message
    fake_reporter = []
    r = OasAgent::Agent::RubyReceiver.new(reporter: fake_reporter, root: "/a/b/c")
    r.push("/home/runner/app/lib/resource_list.rb:100: warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call", ["a", "b"])
    assert_equal "Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call", fake_reporter.first[:message]
  end

  def test_leaves_non_kwargs_messages_unchanged
    fake_reporter = []
    r = OasAgent::Agent::RubyReceiver.new(reporter: fake_reporter, root: "/a/b/c")
    r.push("/home/runner/app/lib/resource_list.rb:100: warning: Using the last argument as keyword parameters is OK, carry on", ["a", "b"])
    assert_equal "/home/runner/app/lib/resource_list.rb:100: warning: Using the last argument as keyword parameters is OK, carry on", fake_reporter.first[:message]
  end

  def test_strips_location_from_keyword_argument_as_last_hash_parameter_message
    fake_reporter = []
    r = OasAgent::Agent::RubyReceiver.new(reporter: fake_reporter, root: "/a/b/c")
    r.push("/home/runner/app/lib/resource_list.rb:100: warning: Passing the keyword argument as the last hash parameter is deprecated", ["a", "b"])
    assert_equal "Passing the keyword argument as the last hash parameter is deprecated", fake_reporter.first[:message]
  end

  def test_leaves_non_keyword_argument_as_last_hash_parameter_messages_unchanged
    fake_reporter = []
    r = OasAgent::Agent::RubyReceiver.new(reporter: fake_reporter, root: "/a/b/c")
    r.push("/home/runner/app/lib/resource_list.rb:100: warning: Passing the keyword argument as the last hash parameter is OK thanks", ["a", "b"])
    assert_equal "/home/runner/app/lib/resource_list.rb:100: warning: Passing the keyword argument as the last hash parameter is OK thanks", fake_reporter.first[:message]
  end
end
