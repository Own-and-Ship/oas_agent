# frozen_string_literal: true

require "pathname"

# Lets us mock out Rails without having to load it all in our tests.
#
# To setup your test class to use this, ensure you set/unset the constant Rails, eg
#
#     def setup
#       # Stub it out and make sure it's reset before each test
#       Object.const_set(:Rails, MockRails)
#       MockRails.reset
#     end
#
#     def teardown
#       # Remove the "stub"
#       Object.__send__(:remove_const, :Rails) if defined?(Rails)
#     end
#
module MockRails
  module VERSION
    MAJOR = 7
  end

  class Railtie
    def self.initializer(name, options = {}, &block)
      MockRails.initializers[name] = {options: options, block: block}
    end
  end

  module_function

  def initializers
    @initializers ||= {}
  end

  def reset
    @initializers = nil
  end

  def env
    @env ||= "test"
  end

  def env=(value)
    @env = value
  end

  def root
    Pathname.new(__dir__).join("..", "tmp").expand_path
  end
end
