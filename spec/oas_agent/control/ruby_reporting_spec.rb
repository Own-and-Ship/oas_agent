# encoding: utf-8
# frozen_string_literal: true

# Older rubies don't have a Warning module, so refer to it by string
RSpec.describe "Warning" do
  before do
    unless defined?(::Warning)
      skip "Warning not defined on Ruby #{RUBY_VERSION}"
    end
  end

  describe ".warn" do
    context "with deprecation ruby warnings" do
      it "forwards warnings to the agent"

      context "with suppress_ruby_warnings enabled" do
        it "does not call original warn"
      end
    end

    context "with non-deprecation ruby warnings" do
      it "does not forward warnings to the agent"

      context "with suppress_ruby_warnings enabled" do
        it "does not call original warn"
      end
    end
  end
end
