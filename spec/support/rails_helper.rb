# encoding: utf-8
# frozen_string_literal: true

require "pathname"

# Lets us mock out Rails without having to load it all in our tests.
module RailsHelper
  module MockRails
    module VERSION
      STRING = "7.0.0"
      MAJOR = 7
    end

    class Railtie
      def self.initializer(name, options = {}, &block)
        MockRails.initializers[name] = {:options => options, :block => block}
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

    def logger
      @logger ||= Logger.new("/dev/null")
    end

    def root
      Pathname.new(__FILE__).dirname.join("..", "tmp").expand_path
    end
  end

  def self.included(base)
    base.before(:each) do
      RailsHelper::MockRails.reset
      stub_const("Rails", RailsHelper::MockRails)
    end
  end
end
