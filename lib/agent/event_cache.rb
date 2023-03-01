# encoding: utf-8
# frozen_string_literal: true

module OasAgent
  module Agent
    class EventCache
      DATA_INDEXES = {
        event_hash: 0,
        message: 1,
        software: 2,
        callstack: 3,
        software_version: 4,
        program_root: 5,
        counts: 6
      }.freeze

      def initialize(event_hash, message, software, software_version, callstack, program_root)
        @event_data = [
          event_hash,
          message,
          software,
          callstack,
          software_version,
          program_root,
          0
        ]
      end

      def increment
        @event_data[DATA_INDEXES[:counts]] += 1
      end

      def for_serialization
        @event_data
      end

      class << self
        def hash_for_event_data(message: "", software: "", version: "", callstack: [], program_root: "")
          Digest::SHA256.hexdigest(callstack.join("") + message + software + version + program_root)
        end
      end
    end
  end
end
