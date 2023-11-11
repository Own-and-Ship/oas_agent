require "test_helper"

class OasAgentControlTest < Minitest::Test
  def test_warning_injection
    fake_warning = Module.new do
      def warn(_)
      end
    end

    refute fake_warning.ancestors.include?(OasAgent::Control::RubyReporting)
    OasAgent::Control.instance.__send__(:insert_ruby_deprecation_behaviour, fake_warning)
    assert fake_warning.ancestors.include?(OasAgent::Control::RubyReporting)
  end
end
