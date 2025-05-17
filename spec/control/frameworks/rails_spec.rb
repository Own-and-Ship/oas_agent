# encoding: utf-8
# frozen_string_literal: true

require "control/frameworks/rails"

RSpec.describe OasAgent::Control::Frameworks::Rails do
  subject { described_class.new }

  describe "#revision" do
    subject(:revision) { described_class.new.revision }

    it "defaults to nil" do
      expect(revision).to be_nil
    end
  end
end
