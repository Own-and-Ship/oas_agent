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

        def revision
          # Development running directly on machine:
          #   git sha should be available from git command/.git folder. Do we need to care about dirty state?
          #
          # Development inside containers/running remotely: (VSCode's .development thing is probably 95% of these cases)
          #   Presumably .git folder available still. If stripped we'd have no idea.
          #
          # Heroku:
          #   Git SHA not available at runtime by default. The dashboard shows what revision the last deploy is. .git folder stripped
          #   during build phase.
          #
          #   ENV["SOURCE_VERSION"] available during build phase, write it to ./REVISION file with a custom buildpack?
          #
          #   heroku labs has dyno-metadata which makes ENV["HEROKU_SLUG_COMMIT"] available at runtime
          #
          # Capistrano:
          #   .git folder stripped during "build" phase (exported from git sha as archive tarfile to unpack into release folder.) Writes the git sha to
          #   ./REVISION file in root of release. Readable at runtime.
          #
          # Rails default docker (ie, Kamal, ECS, K8s):
          #   Doesn't write anything out for git version. .git folder ignored in .dockerignore out the box.
          #
          #   Could add snippet to write out git sha to ./REVISION file? Or add through envariable in Dockerfile? Would need custom snippet - possibly
          #   raise patch upstream for it with superfly/dockerfile-rails?
          #
          # Something else?
          #   Accept it through the yml config file as top level key. Also accept via envariable (OAS_APP_REVISION?) if present.
          #
          #   Document for people to add in their environment/setup/process.
        end
      end
    end
  end
end
