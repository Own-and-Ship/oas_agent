# encoding: utf-8
# frozen_string_literal: true

require "agent/version"
require "control"

# These are required to load the config currently. Rails >= 4 only.
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/hash/deep_merge"

if defined?(Rails::VERSION)
  require "oas_agent/railtie"
end
