# encoding: utf-8
# frozen_string_literal: true

require "support/rails_helper"

RSpec.describe OasAgent::Agent::Receiver do
  include RailsHelper

  subject(:receiver) { described_class.new(reporter, "/some/root") }

  let(:reporter) { instance_double(OasAgent::Agent::Reporter, :push => nil) }

  describe "#call" do
    subject(:call) { receiver.call(message, callstack) }

    let(:message) { "Some deprecation message" }
    let(:callstack) { ["/path/to/some/file.rb:123:in `some_method'"] }

    it "pushes the deprecation into the reporter" do
      call

      expect(reporter).to have_received(:push).with(hash_including(
        :type => "rails",
        :message => message,
        :callstack => callstack
      ))
    end
  end
end
