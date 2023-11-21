# encoding: utf-8
# frozen_string_literal: true

require "agent/configuration/manager"
require "singleton"

module OasAgent
  module Agent
    class RubyReceiver
      # These are deprecations (usually from Ruby) where the location is
      # included in the deprecation warning. This effectively creates duplicate
      # deprecations all with the same underlying cause, when we really want
      # them to be treated as one single deprecation type.
      STRIPPABLE_SUFFIXES = [
        "Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call",
        "Passing the keyword argument as the last hash parameter is deprecated"
      ].freeze

      def initialize(options = {})
        @reporter = options.fetch(:reporter)
        @rails_root = options.fetch(:root)
      end

      def push(message, callstack)
        message = {
          type: "ruby",
          version: RUBY_VERSION,
          message: strip_path_prefixed_message(message).strip,
          callstack: callstack.map(&:to_s)
        }

        @reporter.push(message)
      rescue ThreadError => e
        OasAgent::AgentContext.logger.warn("Unable to handle Own & Ship message, the receive queue was full. You may need to configure a larger queue or more reporting workers: #{e}")
      end

      private

      def strip_path_prefixed_message(message)
        STRIPPABLE_SUFFIXES.detect( ->{ message }) { |suffix| message.end_with?(suffix) }
      end

      def config
        OasAgent::AgentContext.config
      end
    end
  end
end
