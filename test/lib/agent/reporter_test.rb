require "test_helper"
require "support/mock_rails"

class OasAgentAgentReporterTest < Minitest::Test

  def setup
    # Stub it out and make sure it's reset before each test
    Object.const_set(:Rails, MockRails)
    MockRails.reset

    # Ensure we have default config in place
    OasAgent::AgentContext.config.integrate(OasAgent::Agent::Configuration::DefaultSource.new.to_h)
  end

  def teardown
    # Remove the "stub"
    Object.__send__(:remove_const, :Rails) if defined?(Rails)
  end

  def test_instance_returns_same_object
    first = OasAgent::Agent::Reporter.instance
    second = OasAgent::Agent::Reporter.instance
    assert_equal first.object_id, second.object_id
  end
end
