require "oas_agent"

module OasAgent
  class Railtie < Rails::Railtie
    initializer "oas_agent.inject_behaviour", :before => "active_support.deprecation_behavior" do |app|
      existing_setting = app.config.active_support.deprecation

      # Rails 3+: message, callstack
      # Rails 5.2+: message, callstack, deprecation_horizon, gem_name
      # Rails 7.1+: message, callstack, deprecator
      oas_agent_listener = lambda do |message, callback, *args|
        OasAgent::AgentContext.agent.receiver.call(message, callback, *args)
      end

      app.config.active_support.deprecation = [*existing_setting, oas_agent_listener].compact
    end

    initializer "oas_agent.start_agent", :before => :load_config_initializers do |app|
      Rails.logger.info "Initialising the OAS Ruby agent"
      OasAgent::Control.instance.init(:config => app.config)
    end
  end if Rails::VERSION::MAJOR.to_i >= 3
end
