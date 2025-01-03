lib = File.expand_path("lib", File.dirname(__FILE__))
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "oas_agent/version"

Gem::Specification.new do |spec|
  spec.name          = "oas_agent"
  spec.version       = OasAgent::VERSION
  spec.authors       = ["Will Jessop"]
  spec.email         = ["will@willj.net"]

  spec.summary       = %q{The Own & Ship ruby agent}
  spec.description   = %q{The Own & Ship ruby agent, reports deprecations and modernisation metrics to the Own & Ship web app}
  spec.homepage      = "https://github.com/wjessop/oas_agent"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/wjessop/oas_agent"
    spec.metadata["changelog_uri"] = "https://github.com/wjessop/oas_agent/blob/master/CHANGELOG.md"
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Because we're asking clients to include this gem in their app with an
  # unknown Ruby version we can't pin the version here as it could conflict with
  # the environment the gem is runnign in.
  spec.add_dependency "msgpack"

  # Older rubies shipped these in stdlib, newer ones need the dependency
  if "3.3.0" <= RUBY_VERSION
    spec.add_dependency "base64"
  end
  if "3.4.0" <= RUBY_VERSION
    spec.add_dependency "logger"
    spec.add_dependency "ostruct"
  end

  # Development dependencies must be version specced to work from Ruby 1.9.3 up to Ruby head
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "fakeweb", "~> 1.3"
end
