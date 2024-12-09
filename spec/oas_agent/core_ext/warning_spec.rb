# encoding: utf-8
# frozen_string_literal: true

require "oas_agent/core_ext/warning"

# Older rubies don't have a Warning module, so refer to it by string
RSpec.describe "Warning" do
  if defined?(::Warning)
    # New-er rubies
    describe ".warn" do
      it "method swizzles .warn" do
        expect(Warning.method(:warn)).not_to be_nil
        expect(Warning.method(:original_warn)).not_to be_nil
      end

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
  else
    # Old-er rubies
    it "noops" do
      expect(defined?(Warning)).to be_nil
    end
  end
end
