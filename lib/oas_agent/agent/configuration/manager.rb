# encoding: utf-8
# frozen_string_literal: true

require "oas_agent/agent/configuration/default_source"
require "oas_agent/agent/configuration/environment_source"
require "oas_agent/agent/configuration/yaml_source"

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
          @config = deep_merge(@config, deep_symbolize(config))
        end

        def deep_merge(left, right)
          left.merge(right) do |key, left_val, right_val|
            if left_val.is_a?(Hash) && right_val.is_a?(Hash)
              deep_merge(left_val, right_val)
            else
              right_val
            end
          end
        end

        def deep_symbolize(hash)
          hash.inject({}) do |new_hash, (key, val)|
            new_key = key.respond_to?(:to_sym) ? key.to_sym : key
            new_val = val.is_a?(Hash) ? deep_symbolize(val) : val
            new_hash[new_key] = new_val
            new_hash
          end
        end

        # Internal: Clear the configuration for tests
        def clear
          @config.clear
        end
      end
    end
  end
end
