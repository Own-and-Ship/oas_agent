# encoding: utf-8
# frozen_string_literal: true

require "support/mock_rails"
require "oas_agent"

RSpec.describe OasAgent::Agent::Configuration::Manager do
  before do
    MockRails.reset
    stub_const("Rails", MockRails)
  end

  describe "#integrate" do
    it "handles simple merge with symbolized keys" do
      simple = described_class.new
      simple.integrate({ "log_level" => "info" })

      expect(simple[:log_level]).to eq("info")
    end

    it "handles deep merge replacing empty key" do
      merge_empty = described_class.new
      merge_empty.integrate({ "development" => { "report_immediately" => true } })

      expect(merge_empty[:development][:report_immediately]).to be true
    end

    it "handles deep merge replacing existing key" do
      merge_replace = described_class.new
      merge_replace.integrate({"development" => "enabled"})
      merge_replace.integrate({ "development" => { "report_immediately" => true } })

      expect(merge_replace[:development][:report_immediately]).to be true
    end
  end
end
