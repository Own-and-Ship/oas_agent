# encoding: utf-8
# frozen_string_literal: true

# require "agent/configuration/manager"
require "agent/event_cache"
require "msgpack"
require "base64"

module OasAgent
  module Agent
    class EventsCache
      def initialize(options = {})
        @program_root = options.fetch(:program_root)
        @events = {}
      end

      def add_event(message, software, version, callstack)
        eh = EventCache.hash_for_event_data(message, software, version, callstack, @program_root)

        if !@events.has_key?(eh)
          @events[eh] = EventCache.new(eh, message, software, version, callstack, @program_root)
        end

        @events[eh].increment
      end

      def num_events
        @events.size
      end

      def serializable
        Base64.encode64(
          Zlib::Deflate.deflate(
            @events.map{ |_, event|
              event.for_serialization
            }.to_msgpack
          )
        )
      end
    end
  end
end
