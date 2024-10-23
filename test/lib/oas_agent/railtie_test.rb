require "test_helper"
require "support/mock_rails"

class RailtieTest < Minitest::Test
  def setup
    # Stub it out and make sure it's reset before each test
    Object.const_set(:Rails, MockRails)
    MockRails.reset

    # Then load the railtie fresh, require won't load again if $LOADED_FEATURES contains it
    $LOADED_FEATURES.delete_if { |path| path =~ %r{oas_agent/railtie} }
    require "oas_agent/railtie"
  end

  def teardown
    # Remove the "stub"
    Object.__send__(:remove_const, :Rails) if defined?(Rails)
  end

  def test_adds_inject_behaviour_initializer
    initializer = MockRails.initializers["oas_agent.inject_behaviour"]
    assert initializer, "No initializer found for oas_agent.inject_behaviour"
    assert_equal "active_support.deprecation_behavior", initializer[:options][:before]
  end

  def test_inject_behaviour_initializer_with_no_behaviour
    initializer = MockRails.initializers["oas_agent.inject_behaviour"]
    assert initializer, "No initializer found for oas_agent.inject_behaviour"

    app = OpenStruct.new(config: OpenStruct.new(active_support: OpenStruct.new(deprecation: nil)))

    initializer[:block].call(app)

    assert_equal 1, app.config.active_support.deprecation.size, "Behaviours: #{app.config.active_support.deprecation.inspect}"
    assert_equal Proc, app.config.active_support.deprecation[0].class
  end

  def test_inject_behaviour_initializer_with_a_behaviour
    initializer = MockRails.initializers["oas_agent.inject_behaviour"]
    assert initializer, "No initializer found for oas_agent.inject_behaviour"

    app = OpenStruct.new(config: OpenStruct.new(active_support: OpenStruct.new(deprecation: :log)))

    initializer[:block].call(app)

    assert_equal 2, app.config.active_support.deprecation.size, "Behaviours: #{app.config.active_support.deprecation.inspect}"
    assert_equal :log, app.config.active_support.deprecation[0]
    assert_equal Proc, app.config.active_support.deprecation[1].class
  end

  def test_inject_behaviour_initializer_with_two_behaviours
    initializer = MockRails.initializers["oas_agent.inject_behaviour"]
    assert initializer, "No initializer found for oas_agent.inject_behaviour"

    app = OpenStruct.new(config: OpenStruct.new(active_support: OpenStruct.new(deprecation: [:log, :notify])))

    initializer[:block].call(app)

    assert_equal 3, app.config.active_support.deprecation.size, "Behaviours: #{app.config.active_support.deprecation.inspect}"
    assert_equal :log, app.config.active_support.deprecation[0]
    assert_equal :notify, app.config.active_support.deprecation[1]
    assert_equal Proc, app.config.active_support.deprecation[2].class
  end

  def test_adds_inject_start_agent_initializer
    initializer = MockRails.initializers["oas_agent.start_agent"]
    assert initializer, "No initializer found for oas_agent.start_agent"
    assert_equal :load_config_initializers, initializer[:options][:before]
  end
end
