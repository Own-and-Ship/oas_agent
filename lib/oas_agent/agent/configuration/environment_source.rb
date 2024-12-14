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

          config
        end
      end
    end
  end
end
