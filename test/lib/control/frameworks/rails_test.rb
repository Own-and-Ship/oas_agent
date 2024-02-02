require "test_helper"
require_relative "../../../../lib/control/frameworks/rails"

class ControlFrameworksRailsTest < Minitest::Test
  def instance
    @instance ||= OasAgent::Control::Frameworks::Rails.new
  end

  def test_revision
    assert_nil instance.revision
  end
end
