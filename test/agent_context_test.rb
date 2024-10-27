# frozen_string_literal: true

require "test_helper"

class OasAgentAgentContextTest < Minitest::Test
  def test_context_config
    assert_instance_of OasAgent::Agent::Configuration::Manager, OasAgent::AgentContext.config
  end

  def test_context_agent_assign
    agent = Object.new
    OasAgent::AgentContext.agent = agent
    assert_same agent, OasAgent::AgentContext.agent
  end
end
