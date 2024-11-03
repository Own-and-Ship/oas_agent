# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::Agent::Configuration::DefaultSource do
  describe "#to_h" do
    subject { described_class.new.to_h }
    it "returns a hash of defaults" do
      expect(subject).to be_a(Hash)
    end
  end
end
