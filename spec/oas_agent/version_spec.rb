# encoding: utf-8
# frozen_string_literal: true

RSpec.describe "OasAgent::VERSION" do
  it "is a version number" do
    expect(OasAgent::VERSION).to be_a(String)
    Gem::Version.new(OasAgent::VERSION)
  end
end
