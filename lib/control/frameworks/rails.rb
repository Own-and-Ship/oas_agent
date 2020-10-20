# encoding: utf-8
# frozen_string_literal: true

module OasAgent
  class Control
    module Frameworks
      class Rails < OasAgent::Control
        def root
          root = rails_root.to_s
          if !root.empty?
            root
          else
            @root ||= ENV["APP_ROOT"] || "."
          end
        end

        def rails_root
          RAILS_ROOT if defined?(RAILS_ROOT)
        end

        def env
          @env ||= ENV["RAILS_ENV"] || ENV["APP_ENV"] || ENV["RACK_ENV"] || "development"
        end
      end
    end
  end
end
