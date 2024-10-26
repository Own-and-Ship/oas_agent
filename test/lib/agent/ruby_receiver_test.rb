# frozen_string_literal: true

require "test_helper"
require "agent/agent"

class OasAgentAgentRubyReceiverTest < Minitest::Test
  def test_leaves_messages_it_doesnt_recognise_unchanged
    fake_reporter = []
    r = OasAgent::Agent::RubyReceiver.new(fake_reporter, "/a/b/c")
    r.push("/home/runner/app/lib/resource_list.rb:100: info: Passing the keyword argument as the last hash parameter is OK thanks", ["a", "b"])

    assert_equal "/home/runner/app/lib/resource_list.rb:100: info: Passing the keyword argument as the last hash parameter is OK thanks", fake_reporter.first[:message]
  end

  def test_automatically_strips_location_and_preamble_from_ruby_warnings
    expected_message = "Passing the keyword argument as the last hash parameter is deprecated #{rand(1000)}"
    deprecation_message = "/home/runner/work/someapp/app/models/conference_assignment/assignment.rb:20: warning: #{expected_message}"
    callstack = [
      "/home/runner/work/someapp/app/models/conference_assignment/assignment.rb:20:in `block in perform'",
      "/home/runner/work/someapp/vendor/bundle/ruby/2.7.0/gems/dogstatsd-ruby-4.8.3/lib/datadog/statsd.rb:242:in `time'",
      "/home/runner/work/someapp/app/models/conference_assignment/assignment.rb:15:in `perform'",
      "/home/runner/work/someapp/app/models/conference_assignment.rb:62:in `block in perform'",
      "/home/runner/work/someapp/app/models/concerns/database_locking.rb:68:in `block in try_with_advisory_lock'",
      "/home/runner/work/someapp/app/models/concerns/database_locking.rb:63:in `each'",
      "/home/runner/work/someapp/app/models/concerns/database_locking.rb:63:in `try_with_advisory_lock'",
      "/home/runner/work/someapp/app/models/conference_assignment.rb:51:in `perform'",
      "/home/runner/work/someapp/app/models/mymodel.rb:85:in `block in answer'"
    ]

    fake_reporter = []
    r = OasAgent::Agent::RubyReceiver.new(fake_reporter, "/home/runner/work/someapp")
    r.push(deprecation_message, callstack)

    assert_equal expected_message, fake_reporter.first[:message]
  end
end
