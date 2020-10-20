# encoding: utf-8
# frozen_string_literal: true

require "agent/hostname"

module OasAgent
  module Agent
    class Logger
      LOG_LEVELS = {
        "debug" => ::Logger::DEBUG,
        "info"  => ::Logger::INFO,
        "warn"  => ::Logger::WARN,
        "error" => ::Logger::ERROR,
        "fatal" => ::Logger::FATAL,
      }.freeze

      def initialize
        @log = ::Logger.new(STDOUT)
        set_log_level
        set_log_format
      end

      LOG_LEVELS.keys.each do |level|
        define_method level do |*msgs|
          format_and_send(level, msgs)
        end
      end

      private

      def format_and_send(level, *msgs)
        msgs.flatten.each do |item|
          @log.send(level, item)
        end
        nil
      end

      def set_log_level
        @log.level = Logger.log_level_for(::OasAgent::AgentContext.config[:log_level])
      end

      def self.log_level_for(level)
        LOG_LEVELS.fetch(level.to_s.downcase, ::Logger::INFO)
      end

      def set_log_format
        @hostname = OasAgent::Agent::Hostname.get
        @prefix = '** [Own & Ship]'
        @log.formatter = Proc.new do |severity, timestamp, progname, msg|
          "#{@prefix}[#{timestamp.strftime("%F %H:%M:%S %z")} #{@hostname} (#{$$})] #{severity} : #{msg}\n"
        end
      end
    end
  end
end
