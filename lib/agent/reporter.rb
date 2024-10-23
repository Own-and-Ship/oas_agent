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

      # Create a new agent and start the reporter thread.
      def initialize
        @rails_env = Rails.env
        @rails_root = Rails.root.expand_path.to_s
        @report_queue = SizedQueue.new(OasAgent::AgentContext.config[:reporter][:max_reports_to_queue])
        @pid = Process.pid

        # Reporter thread must be created last as it requires data created previously
        @reporter_thread = start_reporter_thread_if_needed
      end

      # @param data [Object]
      # @param non_block [Boolean] Whether to block if the queue is full
      def push(data, non_block = true)
        if Process.pid != @pid
          puts "Restarting the reporter thread, process pid #{Process.pid} differs from the pid at startup (#@pid) fork detected"
          @reporter_thread.kill
          @pid = Process.pid
          @reporter_thread = start_reporter_thread_if_needed
        elsif !@reporter_thread.alive?
          puts "Restarting the reporter thread, the reporter thread was dead"
          @reporter_thread = start_reporter_thread_if_needed
        end
        @report_queue.push(data, non_block)
        Thread.pass

        if OasAgent::AgentContext.config[:reporter][:send_immediately]
          receive_reports_from_queue
          send_report_batch
        end
      end

      private

      def start_reporter_thread_if_needed
        create_reporter_thread unless OasAgent::AgentContext.config[:reporter][:send_immediately]
      end

      # The agent batches reports and sends them when we have reached either the
      # maximum number of reports to send in one batch, or the maximum time has
      # passed between reports, whichever happens first.
      def create_reporter_thread
        report_thread = Thread.new do
          loop do
            break if @report_queue.closed?
            receive_reports_from_queue
            send_report_batch unless @event_cache.num_events.zero?
          end
        end
        report_thread.priority = 255

        at_exit do
          @report_queue.close
          begin
            Timeout.timeout(1) { report_thread.join }
          rescue Timeout::Error
            OasAgent::AgentContext.logger.warn("Timeout joining report thread during shutdown, report_queue is closed? #{@report_queue.closed?}")
          end
        end

        return report_thread
      end

      def receive_reports_from_queue
        @event_cache = OasAgent::Agent::EventsCache.new(@rails_root)

        # Let's block waiting for the first report to send. This way we avoid
        # looping over an empty reports to send list and throwing a timeout
        # exception every @batched_report_timeout seconds when there are no
        # reports to send.
        report = @report_queue.pop
        return if @report_queue.closed?

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
