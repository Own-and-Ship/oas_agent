# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::Agent::Logger do
  let(:output) { StringIO.new }
  let(:logger) { described_class.new }

  before do
    allow(::Logger).to receive(:new).and_return(::Logger.new(output))
    ::OasAgent::AgentContext.config.integrate(:log_level => "debug")
  end

  %w[debug info warn error fatal].each do |level|
    describe "##{level}" do
      it "logs message" do
        logger.public_send(level, "test message")
        expect(output.string).to include("test message")
        expect(output.string).to include(level.upcase)
      end
    end
  end
end
