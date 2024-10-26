# encoding: utf-8
# frozen_string_literal: true

require "test_helper"

class OasAgentAgentConfigurationYamlSourceTest < Minitest::Test
  def test_loads_config_for_and_environment_including_aliases
    log = StringIO.new
    config = OasAgent::Agent::Configuration::YamlSource.new(
      File.join(File.dirname(__FILE__), "yaml_samples", "with_aliases.yml"),
      "production",
      logger = Logger.new(log)
    ).to_h

    assert_equal "Someapp", config["app_name"]
    assert config["enabled"]
  end
end
