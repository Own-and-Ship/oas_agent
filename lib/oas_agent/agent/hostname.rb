# encoding: utf-8
# frozen_string_literal: true

require "socket"

module OasAgent
  module Agent
    module Hostname
      extend self

      LOCALHOSTS = %w[
        localhost
        0.0.0.0
        127.0.0.1
        0:0:0:0:0:0:0:1
        0:0:0:0:0:0:0:0
        ::1
        ::
      ].freeze

      if String.method_defined?(:force_encoding)
        def get
          Socket.gethostname.force_encoding(Encoding::UTF_8)
        end
      else
        # Ruby < 1.9.0
        def get
          Socket.gethostname
        end
      end

      def dyno_name
        ENV["DYNO"]
      end

      def self.local? host_or_ip
        LOCALHOSTS.include?(host_or_ip)
      end

      def self.get_external host_or_ip
        local?(host_or_ip) ? get : host_or_ip
      end
    end
  end
end
