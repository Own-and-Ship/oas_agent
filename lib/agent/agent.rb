# encoding: utf-8
# frozen_string_literal: true

require "singleton"
require "agent/reporter"
require "agent/receiver"
require "agent/ruby_receiver"

module OasAgent
  module Agent

    extend self

    def config
      @config ||= Configuration::Manager.new
    end

    class Base
      include Singleton

      attr_reader :receiver, :ruby_receiver

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
        @ruby_receiver = RubyReceiver.new(reporter: @reporter)
      end
    end
  end
end
