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
          message: cleanup_ruby_kwargs_warning_message(message).strip,
          callstack: callstack.map(&:to_s)
        }

        @reporter.push(message)
      rescue ThreadError => e
        OasAgent::AgentContext.logger.warn("Unable to handle Own & Ship message, the receive queue was full. You may need to configure a larger queue or more reporting workers: #{e}")
      end

      private

      # Ruby kwargs warnings include the file path and line number and this
      # causes a new deprecation message to get created for each code location,
      # so we remove the unique location from the message. We will get that data
      # anyway in the callstack.
      def cleanup_ruby_kwargs_warning_message(message)
        kwargs_message = "Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call"
        if message.end_with? kwargs_message
          return kwargs_message
        else
          return message
        end
      end

      def config
        OasAgent::AgentContext.config
      end
    end
  end
end
