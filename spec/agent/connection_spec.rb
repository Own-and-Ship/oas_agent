# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::Agent::Connection do
  before do
    OasAgent::AgentContext.config.integrate(OasAgent::Agent::Configuration::DefaultSource.new.to_h)
    OasAgent::AgentContext.config.integrate(
      :agent_key => "test_key",
      :api => { :host => "ownandship.test" },
    )
  end

  after do
    OasAgent::AgentContext.config.clear
  end

  it "makes a request" do
    connection = OasAgent::Agent::Connection.new
    data = { "key" => "value" }

    FakeWeb.register_uri(:post, "https://ownandship.test/api/report/deprecation",
      :headers => {
        "X-Api-Token" => "test_key",
        "User-Agent" => "oas-agent/#{OasAgent::VERSION} (ruby)",
      }
    )

    connection.send_request(data)
  end
end
