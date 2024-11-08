# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::Control do
  describe ".instance" do
    it "returns a singleton instance" do
      instance1 = described_class.instance
      instance2 = described_class.instance
      expect(instance1).to be(instance2)
    end
  end

  describe ".new_instance" do
    it "returns a new instance"
  end

  describe "#init" do
    it "initializes the agent"
  end
end
