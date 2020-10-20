# encoding: utf-8
# frozen_string_literal: true

require "agent/agent"
require "agent/logger"
require "agent_context"

module OasAgent
  class Control
    module InstanceMethods
      attr_writer :env

      def init(options={})
        env = determine_env(options)

        OasAgent::AgentContext.logger = OasAgent::Agent::Logger.new
        OasAgent::AgentContext.agent = OasAgent::Agent::Base.instance

        configure_agent(env, options)
        env_name = options.delete(:env) and self.env = env_name

        OasAgent::AgentContext.logger.info("Starting the Own & Ship agent in the #{env} environment for application #{OasAgent::AgentContext.config[:app_name]}")

        start_agent
        insert_deprecation_behaviour
      end

      private

      def configure_agent(env, options)
        OasAgent::AgentContext.config.integrate(OasAgent::Agent::Configuration::DefaultSource.new.to_h)
        OasAgent::AgentContext.config.integrate(OasAgent::Agent::Configuration::YamlSource.new(yaml_config_file_path, env).to_h)
        OasAgent::AgentContext.config.integrate(OasAgent::Agent::Configuration::EnvironmentSource.new.to_h)
      end

      def determine_env(options)
        (options[:env] || self.env).to_s
      end

      def start_agent
        OasAgent::AgentContext.agent.start
      end

      def insert_deprecation_behaviour
        ActiveSupport::Deprecation.behavior << OasAgent::AgentContext.agent.receiver
      end

      def yaml_config_file_path
        File.join(self.root, "config", "oas.yml")
      end

      def api_host
        "localhost"
      end

      def api_port
        3000
      end
    end

    include InstanceMethods
  end
end
