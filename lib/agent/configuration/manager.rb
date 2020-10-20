# encoding: utf-8
# frozen_string_literal: true

require "agent/configuration/default_source"
require "agent/configuration/yaml_source"
require "agent/configuration/environment_source"

module OasAgent
  module Agent
    module Configuration
      class Manager
        def initialize
          @config = {}
        end

        def [](key)
          @config[key]
        end

        def integrate(config)
          @config.deep_merge!(config.deep_symbolize_keys)
        end
      end
    end
  end
end
