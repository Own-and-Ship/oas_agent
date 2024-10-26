# encoding: utf-8
# frozen_string_literal: true

require "singleton"
require "agent/connection"
require "agent/events_cache"
require "digest"
require "timeout"

module OasAgent
  module Agent
    class Reporter
      include Singleton

      # Used for older rubies before SizedQueue#close was introduced
      QUEUE_CLOSED = Object.new

      # Create a new agent and start the reporter thread.
      def initialize
        @rails_env = Rails.env
        @rails_root = Rails.root.expand_path.to_s
        @report_queue = SizedQueue.new(OasAgent::AgentContext.config[:reporter][:max_reports_to_queue])
        @pid = Process.pid

        # Reporter thread must be created last as it requires data created previously
        @reporter_thread = create_reporter_thread unless OasAgent::AgentContext.config[:reporter][:send_immediately]

        at_exit { close }
      end

      # @param data [Object]
      # @param non_block [Boolean] Whether to block if the queue is full
      def push(data, non_block = true)
        if @reporter_thread
          if @pid != Process.pid
            OasAgent::AgentContext.logger.warn("Fork detected (#{@pid} -> #{Process.pid}), restarting reporter thread")
            restart
          elsif !@reporter_thread.alive?
            OasAgent::AgentContext.logger.warn("Reporter thread not alive, restarting reporter thread")
            restart
          end
        end

        @report_queue.push(data, non_block)

        if OasAgent::AgentContext.config[:reporter][:send_immediately]
          receive_reports_from_queue
          send_report_batch
        end
      end

      # Closes down reporter
      # Attempts to shutdown gracefully, but will force close if it takes too long
      def close
        self.class.instance_variable_get(:@singleton__mutex__).synchronize do
          if @report_queue.respond_to?(:close)
            @report_queue.close
          else
            @report_queue.push QUEUE_CLOSED
          end

          begin
            Timeout.timeout(1) { @reporter_thread.join }
          rescue Timeout::Error
            OasAgent::AgentContext.logger.warn("Timeout joining report thread during shutdown")
          end
        end
      end

      # Expects to be called after a process has forked to restart now-dead thread
      def restart
        self.class.instance_variable_get(:@singleton__mutex__).synchronize do
          @reporter_thread.kill if @reporter_thread.alive?
          @reporter_thread = create_reporter_thread

          # Update in case of forked process
          @pid = Process.pid
        end
      end

      private

      # The agent batches reports and sends them when we have reached either the
      # maximum number of reports to send in one batch, or the maximum time has
      # passed between reports, whichever happens first.
      def create_reporter_thread
        Thread.new do
          loop do
            break if @report_queue.respond_to?(:closed?) && @report_queue.closed?
            receive_reports_from_queue
            send_report_batch unless @event_cache.num_events.zero?
          end
        end
      end

      def receive_reports_from_queue
        @event_cache = OasAgent::Agent::EventsCache.new(@rails_root)

        # Let's block waiting for the first report to send. This way we avoid
        # looping over an empty reports to send list and throwing a timeout
        # exception every @batched_report_timeout seconds when there are no
        # reports to send.
        report = @report_queue.pop
        if @report_queue.respond_to?(:closed?)
          return if @report_queue.closed?
        else
          # This breaks out of the loop in create_reporter_thread in old rubies
          raise StopIteration if report == QUEUE_CLOSED
        end

        @event_cache.add_event(report[:message], report[:type], report[:version], report[:callstack]) unless report.nil?

        # We only activate the timeout after the first report is received, there
        # is no point setting a delivery timeout on nothing
        Timeout::timeout(OasAgent::AgentContext.config[:reporter][:batched_report_timeout]) do
          while @event_cache.num_events < OasAgent::AgentContext.config[:reporter][:max_reports_to_batch] do
            report = @report_queue.pop
            return if @report_queue.closed?
            @event_cache.add_event(report[:message], report[:type], report[:version], report[:callstack])
          end
        end
      rescue Timeout::Error
        # Do nothing, we just want to fall through to sending the reports we have
        # accumulated
      end

      def send_report_batch
        return unless OasAgent::AgentContext.config[:enabled]
        @connection ||= Connection.new
        time = Time.now.utc

        @connection.send_request(
          {
            environment: @rails_env,
            date: time.to_date.to_s,
            hour: time.hour,
            reports: @event_cache.serializable
          }
        )
      end
    end
  end
end
