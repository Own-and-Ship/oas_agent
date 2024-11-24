# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::Agent::Configuration::YamlSource do
  context "with a yaml file containing alias' given" do
    let(:logger) { Logger.new(StringIO.new) }
    let(:aliases_file) { File.join(File.dirname(__FILE__), "../../../data/yaml_source_with_aliases.yml") }

    subject(:config) {
      OasAgent::Agent::Configuration::YamlSource.new(aliases_file, "production", logger).to_h
    }

    it "loads config for the correct environment" do
      expect(config["app_name"]).to eq("Someapp")
      expect(config["enabled"]).to be_truthy
    end
  end
end
