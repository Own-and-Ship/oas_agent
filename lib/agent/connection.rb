# encoding: utf-8
# frozen_string_literal: true

require "net/https"
require "json"

module OasAgent
  module Agent
    class Connection
      CONNECTION_ERRORS = [Net::HTTPRequestTimeOut, Net::HTTPGatewayTimeOut, Net::ReadTimeout, EOFError, SystemCallError, SocketError].freeze

      def initialize
        @default_headers = {
          "Content-Encoding" => OasAgent::AgentContext.config[:api][:reports_encoding],
          "Host"             => OasAgent::AgentContext.config[:api][:host],
          "Accept"           => "text/plain; api_version=#{OasAgent::AgentContext.config[:api][:version]}",
          "X-API-Token"      => OasAgent::AgentContext.config[:agent_key]
        }
      end

      def send_request(data)
        connect unless @conn&.started?

        request = Net::HTTP::Post.new(config[:api][:reports_request_path], @default_headers)
        request["user-agent"] = config[:api][:user_agent]

        request.content_type = config[:api][:reports_content_type]

        unless data_will_fit_down_pipe?(data)
          logger.warning "Payload data size #{data.size} is too large (max #{config[:api][:max_data_size_for_post_bytes]}) and could not not be sent. Consider decreasing the max_reports_to_batch config option."
          return
        end

        request.body = JSON(data)
        attempts = 0

        begin
          response = @conn.request(request)
          @conn.finish unless [200, 201, 204].include? response.code.to_i
        rescue *CONNECTION_ERRORS => e
          refresh_connection
          if attempts < config[:api][:max_retries_per_record]
            logger.debug("Retrying request to #{config[:api][:host]}:#{config[:api][:port]}#{config[:api][:reports_request_path]} after error: #{e}")
            attempts += 1
            retry
          else
            logger.warn("Giving up after #{attempts} attempts to contact the Own & Ship api: #{config[:api][:host]}:#{config[:api][:port]}#{config[:api][:reports_request_path]} after error: #{e}")
          end
        end
      end

      private

      def connect
        if config[:api][:proxy_host]
          logger.debug("Using proxy server #{config[:api][:proxy_host]}:#{config[:api][:proxy_port]}")

          proxy = Net::HTTP::Proxy(
            config[:api][:proxy_host],
            config[:api][:proxy_port],
            config[:api][:proxy_user],
            config[:api][:proxy_pass]
          )
          @conn = proxy.new(config[:api][:host], config[:api][:port])
        else
          @conn = Net::HTTP.new(config[:api][:host], config[:api][:port])
        end

        # @conn.set_debug_output($stdout)

        if config[:api][:enforce_tls] == true
          @conn.use_ssl     = true
          @conn.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end

        @conn.open_timeout       = config[:api][:open_timeout]
        @conn.read_timeout       = config[:api][:read_timeout]
        @conn.write_timeout      = config[:api][:write_timeout]
        @conn.keep_alive_timeout = config[:api][:keepalive_timeout] if @conn.respond_to?(:keep_alive_timeout)
        @conn.close_on_empty_response = true
        @conn.start

        logger.debug("Created net/http for #{@conn.address}:#{@conn.port}")
      end

      def refresh_connection
        @conn.finish if @conn.started?
        connect
      end

      def max_post_data_size
        config[:api][:min_data_size_for_compress_bytes]
      end

      def data_will_fit_down_pipe?(data)
        data.size <= config[:api][:max_data_size_for_post_bytes] ? true : false
      end

      def logger
        OasAgent::AgentContext.logger
      end

      def config
        OasAgent::AgentContext.config
      end
    end
  end
end


