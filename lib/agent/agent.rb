# encoding: utf-8
# frozen_string_literal: true

require "singleton"
require "agent/reporter"
require "agent/receiver"

module OasAgent
  module Agent

    extend self

    def config
      @config ||= Configuration::Manager.new
    end

    class Base
      include Singleton

      attr_reader :receiver

      class << self
        def instance
          @instance ||= new
        end

        def logger
          ::OasAgent::Agent.logger
        end

        def config
          ::OasAgent::Agent.config
        end
      end

      def start
        @reporter = Reporter.instance
        @receiver = Receiver.new(reporter: @reporter)
      end
    end
  end
end
