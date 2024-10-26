# frozen_string_literal: true

require "support/mock_rails"

class ManagerTest < Minitest::Test
  def setup
    # Stub it out and make sure it's reset before each test
    Object.const_set(:Rails, MockRails)
    MockRails.reset
  end

  def teardown
    # Remove the "stub"
    Object.__send__(:remove_const, :Rails) if defined?(Rails)
  end

  def test_integrate
    # Simple merge
    simple = OasAgent::Agent::Configuration::Manager.new
    simple.integrate({ "log_level" => "info" })
    assert_equal "info", simple[:log_level], "Should have symbolized key stored"

    # Deep merge replacing empty key
    merge_empty = OasAgent::Agent::Configuration::Manager.new
    merge_empty.integrate({ "development" => { "report_immediately" => true } })
    assert_equal true, merge_empty[:development][:report_immediately], "Should have symbolized hash stored"

    # Deep merge replacing existing key
    merge_replace = OasAgent::Agent::Configuration::Manager.new
    merge_replace.integrate({"development" => "enabled"})
    merge_replace.integrate({ "development" => { "report_immediately" => true } })
    assert_equal true, merge_replace[:development][:report_immediately], "Should replace string value with symbolized hash"
  end
end
