require "test_helper"

class OasAgentTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::OasAgent::VERSION
  end
end
