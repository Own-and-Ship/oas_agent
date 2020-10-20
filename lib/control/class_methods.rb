# encoding: utf-8
# frozen_string_literal: true

module OasAgent
  class Control
    module ClassMethods
      def instance
        @instance ||= new_instance
      end

      # If we need to deploy to something other than Rails we will determine the
      # framework here
      def new_instance
        require "control/frameworks/rails"
        Frameworks::Rails.new
      end
    end

    extend ClassMethods
  end
end
