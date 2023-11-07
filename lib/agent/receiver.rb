# encoding: utf-8
# frozen_string_literal: true

require "agent/configuration/manager"

module OasAgent
  module Agent
    class Receiver
      def initialize(reporter:, root:)
        @reporter = reporter
        @rails_root = root
        @rails_version = Rails::VERSION::STRING
      end

      def call(message, callstack, *args)
        message = {
          type: "rails",
          version: @rails_version,
          message: message.sub(/\ADEPRECATION WARNING: /, "").sub(/\(called from.+\)/, "").strip,
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
