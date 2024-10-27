require "test_helper"
require "support/mock_rails"

class OasAgentAgentReporterTest < Minitest::Test

  def setup
    # Stub it out and make sure it's reset before each test
    Object.const_set(:Rails, MockRails)
    MockRails.reset

    # Ensure we have default config in place
    OasAgent::AgentContext.config.integrate(OasAgent::Agent::Configuration::DefaultSource.new.to_h)

    # Load the reporter in an isolated way
    Object.const_set(:TestReporter, Class.new(OasAgent::Agent::Reporter))
  end

  def teardown
    # Stop the temporary reporter
    TestReporter.instance.close
    Object.__send__(:remove_const, :TestReporter) if defined?(Reporter)

    # Remove the "stub"
    Object.__send__(:remove_const, :Rails) if defined?(Rails)
  end

  def test_instance_returns_same_object
    object1 = TestReporter.instance
    object2 = TestReporter.instance

    assert_equal object1.object_id, object2.object_id
  end

  def test_close_shuts_down_thread
    thread = TestReporter.instance.instance_variable_get(:@reporter_thread)
    queue = TestReporter.instance.instance_variable_get(:@report_queue)

    TestReporter.instance.close

    if queue.respond_to?(:closed)
      assert queue.closed?, "Reporter report queue should be closed"
    end
    refute thread.alive?, "Reporter thread should not be alive"
  end

  def test_close_shuts_down_slow_thread
    logger = Class.new do
      def messages
        @messages ||= []
      end

      def warn(message)
        self.messages << [:warn, message]
      end
    end

    OasAgent::AgentContext.logger = logger.new

    # Stop us leaking the original thread in test
    TestReporter.instance.instance_variable_get(:@reporter_thread).kill

    # Add a slow thread
    slow_thread = Thread.new { sleep 10 }
    TestReporter.instance.instance_variable_set(:@reporter_thread, slow_thread)

    TestReporter.instance.close

    assert_equal [[:warn, "Timeout joining report thread during shutdown"]], OasAgent::AgentContext.logger.messages
    q = TestReporter.instance.instance_variable_get(:@report_queue)
    if q.respond_to?(:closed)
      assert q.closed?, "Reporter report queue should be closed"
    end

    slow_thread.kill
  end

  def test_no_background_thread_when_send_immediately
    OasAgent::AgentContext.config.integrate({reporter: {send_immediately: true}})

    TestReporter.instance
    assert_nil TestReporter.instance.instance_variable_get(:@reporter_thread)
  end

  def test_close_with_send_immediately
    OasAgent::AgentContext.config.integrate({reporter: {send_immediately: true}})

    TestReporter.instance.close

    assert_nil TestReporter.instance.instance_variable_get(:@reporter_thread)
    q = TestReporter.instance.instance_variable_get(:@report_queue)
    if q.respond_to?(:closed)
      assert q.closed?, "Reporter report queue should be closed"
    end
  end

  def test_restart_with_send_immediately
    OasAgent::AgentContext.config.integrate({reporter: {send_immediately: true}})

    TestReporter.instance.restart

    assert_nil TestReporter.instance.instance_variable_get(:@reporter_thread)
  end
end
