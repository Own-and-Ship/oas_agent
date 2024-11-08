# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::AgentContext do
  it "extends itself" do
    expect(described_class).to be_a(Module)
    expect(described_class.ancestors).to include(described_class)
  end

  describe ".config" do
    it "returns configuration manager"
  end

  describe ".agent" do
    context "with an agent set" do
      it "returns the agent"
    end

    context "without an agent set" do
      it "returns nil"
    end
  end

  describe ".agent=" do
    it "assigns an agent"
  end

  describe ".logger" do
    it "returns the logger"
  end

  describe ".logger=" do
    it "assigns an logger"
  end
end
