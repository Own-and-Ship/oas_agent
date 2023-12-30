require "test_helper"

class InstanceMethodTest < Minitest::Test
  # Fake out from a test purpose how Rails 7.1 works with deprecations
  # This only mimics, not a full implementation
  class MimicRails
    class Deprecators < Array
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def behavior=(obj_or_array)
        Array(obj_or_array).each do |obj|
          raise "Cannot be nil" unless obj
        end
        @options[:behavior] = Array(obj_or_array)
      end
    end

    def self.application
      @application ||= new
    end

    attr_accessor :deprecators
  end

  def setup
    Object.const_set(:Rails, MimicRails)
  end

  def teardown
    Object.__send__(:remove_const, :Rails) if Object.const_defined?(:Rails)
  end

  def test_insert_deprecation_behaviour_rails_71_existing_behaviour
    MimicRails.application.deprecators = MimicRails::Deprecators.new(behavior: :raise)

    OasAgent::AgentContext.agent = OasAgent::Agent::Base.instance
    OasAgent::AgentContext.agent.instance_variable_set(:@receiver, Object.new)

    OasAgent::Control.instance.__send__(:insert_deprecation_behaviour)

    assert_equal [:raise, OasAgent::AgentContext.agent.receiver], MimicRails.application.deprecators.options[:behavior]
  end

  def test_insert_deprecation_behaviour_rails_71_nil_behaviour
    MimicRails.application.deprecators = MimicRails::Deprecators.new(behavior: nil)
    Object.const_set(:Rails, MimicRails)

    OasAgent::AgentContext.agent = OasAgent::Agent::Base.instance
    OasAgent::AgentContext.agent.instance_variable_set(:@receiver, Object.new)

    OasAgent::Control.instance.__send__(:insert_deprecation_behaviour)

    assert_equal [OasAgent::AgentContext.agent.receiver], MimicRails.application.deprecators.options[:behavior]
  ensure
    Object.__send__(:remove_const, :Rails)
  end
end
