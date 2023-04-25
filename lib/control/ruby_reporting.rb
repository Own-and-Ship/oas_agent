# encoding: utf-8
# frozen_string_literal: true

require "oas_agent/control"

module OasAgent
  class Control
    module RubyReporting
      def warn(warning)
        super unless unless OasAgent::AgentContext.config[:common][:suppress_ruby_warnings]
        OasAgent::AgentContext.agent.ruby_receiver.push(warning.strip, caller) if warning.include?("deprecated")
      end
    end
  end
end

::Warning.prepend(OasAgent::Control::RubyReporting)
