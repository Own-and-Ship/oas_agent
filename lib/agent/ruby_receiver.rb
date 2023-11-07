# encoding: utf-8
# frozen_string_literal: true

require "agent/configuration/manager"
require "singleton"

module OasAgent
  module Agent
    class RubyReceiver
      def initialize(reporter:, root:)
        @reporter = reporter
        @rails_root = root
      end

      def push(message, callstack)
        message = {
          type: "ruby",
          version: RUBY_VERSION,
          message: message.strip,
          callstack: callstack.map(&:to_s)
        }

        @reporter.push(message)
      rescue ThreadError => e
        OasAgent::AgentContext.logger.warn("Unable to handle Own & Ship message, the receive queue was full. You may need to configure a larger queue or more reporting workers: #{e}")
      end

      private

      def config
        OasAgent::AgentContext.config
      end
    end
  end
end
