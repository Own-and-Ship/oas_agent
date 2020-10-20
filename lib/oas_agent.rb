# encoding: utf-8
# frozen_string_literal: true

require "agent/version"
require "control"

if defined?(Rails::VERSION)
  if Rails::VERSION::MAJOR.to_i >= 3
    module OasAgent
      class Railtie < Rails::Railtie
        initializer "oas_agent.start_agent", before: :load_config_initializers do |app|
          Rails.logger.info "Initialising the OAS Ruby agent"
          OasAgent::Control.instance.init(:config => app.config)
        end
      end
    end
  end

  if Rails.env.development?
#     require "dev_engine"
  end
end
