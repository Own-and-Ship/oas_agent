# encoding: utf-8
# frozen_string_literal: true

require "singleton"
require "agent/connection"
require "digest"

module OasAgent
  module Agent
    class Reporter
      include Singleton

      # Create a new agent and start the reporter thread.
      def initialize
        @report_queue = SizedQueue.new(OasAgent::AgentContext.config[:reporter][:max_reports_to_queue])
        @reporter_thread = create_reporter_thread unless OasAgent::AgentContext.config[:reporter][:send_immediately]
        @rails_env = Rails.env
        @rails_root = Rails.root.expand_path.to_s
      end

      def push(data, non_block: true)
        @report_queue.push(data, non_block)

        if OasAgent::AgentContext.config[:reporter][:send_immediately]
          receive_reports_from_queue
          send_report_batch
        end
      end

      private

      # The agent batches reports and sends them when we have reached either the
      # maximum number of reports to send in one batch, or the maximum time has
      # passed between reports, whichever happens first.
      def create_reporter_thread
        report_thread = Thread.new do
          loop do
            break if @report_queue.closed?
            receive_reports_from_queue
            send_report_batch unless @batched_reports_to_send.size.zero?
          end
        end

        at_exit do
          @report_queue.close
          report_thread.join
        end
      end

      def receive_reports_from_queue
        # Let's block waiting for the first report to send. This way we avoid
        # looping over an empty reports to send list and throwing a timeout
        # exception every @batched_report_timeout seconds when there are no
        # reports to send.
        @batched_reports_to_send = [@report_queue.pop].compact
        return if @report_queue.closed?

        # We only activate the timeout after the first report is received, there
        # is no point setting a delivery timeout on nothing
        Timeout::timeout(OasAgent::AgentContext.config[:reporter][:batched_report_timeout]) do
          while @batched_reports_to_send.size < OasAgent::AgentContext.config[:reporter][:max_reports_to_batch] do
            report = @report_queue.pop
            return if @report_queue.closed?
            @batched_reports_to_send << report
          end
        end
      rescue Timeout::Error
        # Do nothing, we just want to fall through to sending the reports we have
        # accumulated
      end

      def send_report_batch
        @connection ||= Connection.new

        processed_reports = @batched_reports_to_send.inject({}) do |hash, element|
          location = "#{element[:location][:path]}:#{element[:location][:lineno]}"
          callstack_key = Digest::SHA256.hexdigest(element[:callstack].join(""))

          hash[element[:message]] ||= {}
          hash[element[:message]][:meta] ||= {}
          hash[element[:message]][:meta][:software_type] = element[:type]
          hash[element[:message]][:meta][:software_version] = element[:version]

          hash[element[:message]][:events] ||= {}
          hash[element[:message]][:events][location] ||= {count: 0, path: element[:location][:path], lineno: element[:location][:lineno]}
          hash[element[:message]][:events][location][:count] += 1

          hash[element[:message]][:events][location][:callstacks] ||= {}
          hash[element[:message]][:events][location][:callstacks][callstack_key] ||= {count: 0}
          hash[element[:message]][:events][location][:callstacks][callstack_key][:count] += 1
          hash[element[:message]][:events][location][:callstacks][callstack_key][:callstack] ||= element[:callstack]

          hash
        end

        @connection.send_request(
          {
            rails_env: @rails_env,
            rails_root: @rails_root,
            reports: processed_reports
          }
        )
      end
    end
  end
end
