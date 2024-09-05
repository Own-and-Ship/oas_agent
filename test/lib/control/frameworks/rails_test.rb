require "test_helper"
require_relative "../../../../lib/control/frameworks/rails"

class ControlFrameworksRailsTest < Minitest::Test
  def setup
    @ENV = ENV.to_h
  end

  def test_revision
    assert_equal "development", OasAgent::Control::Frameworks::Rails.new(_env: @ENV).env
    @ENV["RAILS_ENV"] = "production"
    assert_equal "production", OasAgent::Control::Frameworks::Rails.new(_env: @ENV).env
  end
end
