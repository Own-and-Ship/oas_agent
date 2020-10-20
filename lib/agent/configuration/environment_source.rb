# encoding: utf-8
# frozen_string_literal: true

module OasAgent
  module Agent
    module Configuration
      class EnvironmentSource
        def to_h
          config = {}
          config[:agent_key] = ENV["OAS_AGENT_KEY"] unless ENV["OAS_AGENT_KEY"].blank?

          config
        end
      end
    end
  end
end
