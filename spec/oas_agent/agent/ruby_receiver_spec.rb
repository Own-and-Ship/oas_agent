# encoding: utf-8
# frozen_string_literal: true

require "spec_helper"
require "oas_agent/agent"

RSpec.describe OasAgent::Agent::RubyReceiver do
  subject(:receiver) { described_class.new(reporter, "/some/root") }

  let(:reporter) { instance_double("OasAgent::Agent::Reporter", :push => nil) }

  describe "#push" do
    before { allow(reporter).to receive(:push) }

    context "with custom warning message" do
      let(:message) { "Ruby warning something useful" }
      let(:callstack) { ["a", "b"] }

      it "preserves the original message" do
        receiver.push(message, callstack)

        expect(reporter).to have_received(:push).with(hash_including(
          :type => "ruby",
          :version => RUBY_VERSION,
          :message => message
        ))
      end
    end

    context "with Ruby warning messages prepended with filename/number" do
      let(:message) { "/some/path/file.rb:20: warning: something warning here" }
      let(:callstack) do
        [
          "/some/path/file.rb:20:in `block in perform'",
          "/some/path/file.rb:51:in `perform'"
        ]
      end

      it "strips location and preamble from the warning message" do
        receiver.push(message, callstack)

        expect(reporter).to have_received(:push).with(hash_including(
          :type => "ruby",
          :version => RUBY_VERSION,
          :message => "something warning here"
        ))
      end
    end
  end
end
