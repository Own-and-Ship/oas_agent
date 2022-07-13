# encoding: utf-8
# frozen_string_literal: true

require "agent/configuration/manager"
require "singleton"

module OasAgent
  module Agent
    class RubyReceiver
      def initialize(reporter:)
        @reporter = reporter
        @rails_root = Rails.root.expand_path.to_s
      end

      def push(message, callstack)
        parsed_locations = callstack.map{|c| c.split(":")[0..1] }
        location = parsed_locations.detect{ |location, _| location.starts_with? @rails_root }
        location ||= parsed_locations.first

        message = {
          type: "ruby",
          version: RUBY_VERSION,
          message: message.strip,
          location: {
            path: location[0],
            lineno: location[1]
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
