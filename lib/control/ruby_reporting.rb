# encoding: utf-8
# frozen_string_literal: true

module OasAgent
  class Control
    module RubyReporting
      def warn(warning)
        super unless OasAgent::AgentContext.config[:common][:suppress_ruby_warnings]
        OasAgent::AgentContext.agent.ruby_receiver.push(warning.strip, caller) if warning.include?("deprecated")
      end
    end
  end
end
