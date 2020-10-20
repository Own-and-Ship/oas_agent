# encoding: utf-8
# frozen_string_literal: true

module OasAgent
  module AgentContext
    extend self

    require "agent/configuration"

    def config
      @config ||= Agent::Configuration::Manager.new
    end

    def agent #:nodoc:
      return @agent if @agent
      nil
    end

    def agent=(new_instance) #:nodoc:
      @agent = new_instance
    end

    def logger
      @logger
    end

    def logger=(log)
      @logger = log
    end
  end
end
