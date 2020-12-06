# encoding: utf-8
# frozen_string_literal: true

module ::Warning
  class << self
    alias :original_warn :warn

    def warn(warning)
      original_warn(warning) unless OasAgent::AgentContext.config[:common][:suppress_ruby_warnings]
      OasAgent::AgentContext.agent.ruby_receiver.push(warning.strip, caller) if warning.include?("deprecated")
    end
  end
end
