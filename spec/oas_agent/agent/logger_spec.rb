# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::Agent::Logger do
  subject(:logger) { described_class.new }

  let(:output) { StringIO.new }

  before do
    allow(::Logger).to receive(:new).and_return(::Logger.new(output))

    ::OasAgent::AgentContext.config.integrate(:log_level => "debug")
  end

  %w[debug info warn error fatal].each do |level|
    describe "##{level}" do
      it "logs message" do
        if logger.respond_to?(:public_send)
          logger.public_send(level, "test message")
        else
          # Ruby < 1.9
          logger.__send__(level, "test message")
        end
        expect(output.string).to include("test message")
        expect(output.string).to include(level.upcase)
      end
    end
  end
end
