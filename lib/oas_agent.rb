# encoding: utf-8
# frozen_string_literal: true

require "agent/version"
require "control"

if defined?(Rails::VERSION)
  require "oas_agent/railtie"
end
