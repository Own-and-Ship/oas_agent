# encoding: utf-8
# frozen_string_literal: true

require "oas_agent/version"
require "oas_agent/control"

if defined?(Rails::VERSION)
  require "oas_agent/railtie"
end
