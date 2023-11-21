# encoding: utf-8
# frozen_string_literal: true

require "agent/configuration/manager"
require "singleton"

module OasAgent
  module Agent
    class RubyReceiver
      def initialize(options = {})
        @reporter = options.fetch(:reporter)
        @rails_root = options.fetch(:root)
      end

      def push(message, callstack)
        message = {
          type: "ruby",
          version: RUBY_VERSION,
          message: strip_path_prefixed_message(message, callstack).strip,
          callstack: callstack.map(&:to_s)
        }

        @reporter.push(message)
      rescue ThreadError => e
        OasAgent::AgentContext.logger.warn("Unable to handle Own & Ship message, the receive queue was full. You may need to configure a larger queue or more reporting workers: #{e}")
      end

      private

      # Ruby warning message contain the location that they happened, data that
      # is duplicated in the callstack. This causes each Ruby deprecation
      # message happening at a different location to appear unique so we
      # de-duplicate them by stripping the preamble.
      def strip_path_prefixed_message(message, callstack)
        prefix, message_suffix = message.split(": warning: ", 2)
        if callstack.any? { |callstack_entry| callstack_entry.include?(prefix) }
          message_suffix
        else
          message
        end
      end

      def config
        OasAgent::AgentContext.config
      end
    end
  end
end
