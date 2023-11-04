# encoding: utf-8
# frozen_string_literal: true

require "control/class_methods"
require "control/instance_methods"
require "control/ruby_reporting"

module OasAgent
  class Control
    def insert_ruby_deprecation_behaviour(warning_constant = ::Warning)
      warning_constant.prepend(OasAgent::Control::RubyReporting)
    end
  end
end
