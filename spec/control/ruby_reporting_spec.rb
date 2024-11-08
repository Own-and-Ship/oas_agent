# encoding: utf-8
# frozen_string_literal: true

RSpec.describe Warning do
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
