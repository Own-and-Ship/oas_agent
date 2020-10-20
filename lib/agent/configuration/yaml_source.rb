# encoding: utf-8
# frozen_string_literal: true

module OasAgent
  module Agent
    module Configuration
      class YamlSource
        def initialize(config_path, env)
          @config = {}

          begin
            expanded_config_file_path = File.expand_path(config_path)
            if config_path.empty? || !File.exist?(expanded_config_file_path)
              OasAgent::AgentContext.logger.warning("There was no config file found at #{expanded_config_file_path}")
              return
            end

            OasAgent::AgentContext.logger.info("Reading configuration from #{expanded_config_file_path}")

            raw_file = File.read(expanded_config_file_path)
            erb_file = process_erb(raw_file)
            @config = process_yaml(erb_file, env, expanded_config_file_path)
          rescue ScriptError, StandardError => e
            OasAgent::AgentContext.logger.info("Reading configuration from #{expanded_config_file_path}", e)
          end
        end

        def to_h
          @config
        end

        private

        def process_erb(file)
          begin
            # Exclude lines that are commented out so failing Ruby code in an
            # ERB template commented at the YML level is fine. Leave the line,
            # though, so ERB line numbers remain correct.
            file.gsub!(/^\s*#.*$/, '#')
            ERB.new(file).result(binding)
          rescue ScriptError, StandardError => e
            OasAgent::AgentContext.logger.error("Failed ERB processing configuration file. This is typically caused by a Ruby error in <% %> templating blocks in your oas.yml file.", e)
            nil
          end
        end

        def process_yaml(file, env, path)
          if file
            confighash = YAML.load(file)
            unless confighash.key?(env)
              OasAgent::AgentContext.logger.error("Config file at #{path} doesn't include a '#{env}' section!")
            end

            config = confighash[env] || {}
          end

          config
        end
      end
    end
  end
end
