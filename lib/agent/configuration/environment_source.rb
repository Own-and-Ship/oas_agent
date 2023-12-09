# encoding: utf-8
# frozen_string_literal: true

module OasAgent
  module Agent
    module Configuration
      class EnvironmentSource
        def to_h
          config = {}
          if (key = ENV["OAS_AGENT_KEY"]) && key != ""
            config[:agent_key] = key
          end

          if ENV["OAS_ADDR"] && ENV["OAS_ADDR"] != ""
            require "uri"
            oas_addr = URI.parse(ENV["OAS_ADDR"])

            config[:api] ||= {}
            config[:api][:host] = oas_addr.host
            config[:api][:port] = oas_addr.port
            config[:api][:enforce_tls] = (oas_addr.scheme == "https")
          end

          config
        end
      end
    end
  end
end
