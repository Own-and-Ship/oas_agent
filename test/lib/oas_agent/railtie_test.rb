require "test_helper"
require "ostruct"
require "support/mock_rails"

class OasAgentRailtieTest < Minitest::Test
  include Support::MockRails::TestHelper

  def setup
    # Then load the railtie fresh, require won't load again if $LOADED_FEATURES contains it
    $LOADED_FEATURES.delete_if { |path| path =~ %r{oas_agent/railtie} }
    require "oas_agent/railtie"
  end

  def test_adds_inject_behaviour_initializer
    initializer = Support::MockRails.initializers["oas_agent.inject_behaviour"]

    assert initializer, "No initializer found for oas_agent.inject_behaviour"
    assert_equal "active_support.deprecation_behavior", initializer[:options][:before]
  end

  def test_inject_behaviour_initializer_with_no_behaviour
    initializer = Support::MockRails.initializers["oas_agent.inject_behaviour"]

    assert initializer, "No initializer found for oas_agent.inject_behaviour"

    app = OpenStruct.new(config: OpenStruct.new(active_support: OpenStruct.new(deprecation: nil)))

    initializer[:block].call(app)

    assert_equal 1, app.config.active_support.deprecation.size, "Behaviours: #{app.config.active_support.deprecation.inspect}"
    assert_instance_of Proc, app.config.active_support.deprecation[0]
  end

  def test_inject_behaviour_initializer_with_a_behaviour
    initializer = Support::MockRails.initializers["oas_agent.inject_behaviour"]

    assert initializer, "No initializer found for oas_agent.inject_behaviour"

    app = OpenStruct.new(config: OpenStruct.new(active_support: OpenStruct.new(deprecation: :log)))

    initializer[:block].call(app)

    assert_equal 2, app.config.active_support.deprecation.size, "Behaviours: #{app.config.active_support.deprecation.inspect}"
    assert_equal :log, app.config.active_support.deprecation[0]
    assert_instance_of Proc, app.config.active_support.deprecation[1]
  end

  def test_inject_behaviour_initializer_with_two_behaviours
    initializer = Support::MockRails.initializers["oas_agent.inject_behaviour"]

    assert initializer, "No initializer found for oas_agent.inject_behaviour"

    app = OpenStruct.new(config: OpenStruct.new(active_support: OpenStruct.new(deprecation: [:log, :notify])))

    initializer[:block].call(app)

    assert_equal 3, app.config.active_support.deprecation.size, "Behaviours: #{app.config.active_support.deprecation.inspect}"
    assert_equal :log, app.config.active_support.deprecation[0]
    assert_equal :notify, app.config.active_support.deprecation[1]
    assert_instance_of Proc, app.config.active_support.deprecation[2]
  end

  def test_adds_inject_start_agent_initializer
    initializer = Support::MockRails.initializers["oas_agent.start_agent"]

    assert initializer, "No initializer found for oas_agent.start_agent"
    assert_equal :load_config_initializers, initializer[:options][:before]
  end
end
