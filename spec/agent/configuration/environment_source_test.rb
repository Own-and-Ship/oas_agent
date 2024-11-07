# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::Agent::Configuration::EnvironmentSource do
  subject(:config) { described_class.new.to_h }

  context "when the environment specifies a key value" do
    before do
      stub_const("ENV", {"OAS_AGENT_KEY" => "alohomora"})
    end

    it "returns the key in config" do
      expect(config).to include(agent_key: "alohomora")
    end
  end

  context "when the environment specifies a blank value" do
    before do
      stub_const("ENV", {"OAS_AGENT_KEY" => ""})
    end

    it "does not return key in config" do
      expect(config).not_to include(:agent_key)
    end
  end

  context "when the environment does not contain a key" do
    before do
      stub_const("ENV", {})
    end

    it "does not return key in config" do
      expect(config).not_to include(:agent_key)
    end
  end
end
