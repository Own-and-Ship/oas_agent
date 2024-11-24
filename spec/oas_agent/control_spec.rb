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
    it "sets up the agent"
    it "sets up the logger"

    context "with active_support.report_deprecations set to false" do
      it "warns the user and sets it to true"
    end

    context "with active_support.report_deprecations set to true" do
      it "does nothing"
    end

    context "with active_support.report_deprecations not supported by rails" do
      it "does nothing"
    end

    context "with ruby deprecations reporting enabled" do
      it "inserts the ruby deprecation behaviour"
    end

    context "with ruby deprecations reporting disabled" do
      it "does not insert the ruby deprecation behaviour"
    end
  end
end
