# encoding: utf-8
# frozen_string_literal: true

require 'agent/configuration/manager'

module OasAgent
  module Agent
    class Receiver
      def initialize(reporter:)
        @reporter = reporter
        @rails_root = Rails.root.expand_path.to_s
      end

      def call(message, callstack, *args)
        return unless config[:enabled]

        location = callstack.detect{ |location| location.absolute_path&.starts_with? @rails_root }
        location ||= callstack.first

        message = {
          type: "rails",
          message: message.sub(/\ADEPRECATION WARNING: /, "").sub(/\(called from.+\)/, "").strip,
          location: {
            path: location.absolute_path,
            lineno: location.lineno
          },
          callstack: callstack
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
