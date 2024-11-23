# encoding: utf-8
# frozen_string_literal: true

RSpec.describe OasAgent::Agent::Hostname do
  it "extends itself" do
    expect(described_class).to be_a(Module)
    expect(described_class.ancestors).to include(described_class)
  end

  describe ".get" do
    subject { described_class.get }
    it "returns the system hostname as utf8" do
      expect(subject).to be_a(String)
      expect(subject.encoding).to eq(Encoding::UTF_8)
      expect(subject).to eq(Socket.gethostname)
    end
  end

  describe ".dyno_name" do
    it "returns the current dyno name from Heroku"
  end

  describe ".local?" do
    it "identifies localhost addresses" do
      expect(described_class.local?("localhost")).to be(true)
      expect(described_class.local?("127.0.0.1")).to be(true)
      expect(described_class.local?("::1")).to be(true)
      expect(described_class.local?("example.com")).to be(false)
    end
  end

  describe ".get_external" do
    it "returns hostname for local addresses" do
      expect(described_class.get_external("localhost")).to eq(Socket.gethostname)
    end

    it "returns input for non-local addresses" do
      expect(described_class.get_external("example.com")).to eq("example.com")
    end
  end
end
