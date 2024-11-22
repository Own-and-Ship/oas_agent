# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::Agent do
  describe ".config" do
    it "returns a config manager" do
      expect(described_class.config).to be_a(OasAgent::Agent::Configuration::Manager)
    end
  end

  describe OasAgent::Agent::Base do
    describe ".instance" do
      it "returns a singleton instance" do
        instance1 = described_class.instance
        instance2 = described_class.instance
        expect(instance1).to be(instance2)
      end
    end

    describe ".config" do
      it "returns the agent config"
    end

    describe ".logger" do
      it "returns the agent logger"
    end

    describe "#start" do
      it "starts the agent"
    end

    describe "#receiver" do
      it "returns the receiver"
    end

    describe "#ruby_receiver" do
      it "returns the ruby_receiver"
    end
  end
end
