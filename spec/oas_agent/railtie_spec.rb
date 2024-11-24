# encoding: utf-8
# frozen_string_literal: true

require "ostruct"
require "support/rails_helper"

RSpec.describe "OasAgent::Railtie" do
  include RailsHelper

  before do
    $LOADED_FEATURES.delete_if { |path| path =~ %r{oas_agent/railtie} }
    # We need to have mocked Rails before loading this file
    require "oas_agent/railtie"
  end

  let(:app) {
    OpenStruct.new(
      config: OpenStruct.new(
        active_support: OpenStruct.new(
          deprecation: deprecation_setting
        )
      )
    )
  }
  let(:deprecation_setting) { [] }

  describe "initializer oas_agent.inject_behaviour" do
    subject { Rails.initializers["oas_agent.inject_behaviour"]}

    it "is registered correctly" do
      expect(subject).not_to be_nil
      expect(subject[:options][:before]).to eq("active_support.deprecation_behavior")
    end

    context "with one deprecation behaviour set" do
      let(:deprecation_setting) { :log }

      it "injects listener to active_support.deprecation" do
        subject[:block].call(app)

        expect(app.config.active_support.deprecation).to match([:log, an_instance_of(Proc)])
      end
    end

    context "with multiple deprecation behaviours set" do
      let(:deprecation_setting) { [:log, :warn] }

      it "injects listener to active_support.deprecation" do
        subject[:block].call(app)

        expect(app.config.active_support.deprecation).to match([:log, :warn, an_instance_of(Proc)])
      end
    end
  end

  describe "initializer oas_agent.start_agent" do
    subject { Rails.initializers["oas_agent.start_agent"]}

    it "is registered correctly" do
      expect(subject).not_to be_nil
      expect(subject[:options][:before]).to eq(:load_config_initializers)
    end

    it "initializes the OAS Ruby agent" do
      allow(OasAgent::Control.instance).to receive(:init).and_return(true)

      subject[:block].call(app)

      expect(OasAgent::Control.instance).to have_received(:init).with(config: app.config)
    end
  end
end
