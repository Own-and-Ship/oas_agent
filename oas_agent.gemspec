lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "agent/version"

Gem::Specification.new do |spec|
  spec.name          = "oas_agent"
  spec.version       = OasAgent::VERSION
  spec.authors       = ["Will Jessop"]
  spec.email         = ["will@willj.net"]

  spec.summary       = %q{The Own & Ship ruby agent}
  spec.description   = %q{The Own & Ship ruby agent, reports deprecations and modernisation metrics to the Own & Ship web app}
  spec.homepage      = "https://github.com/wjessop/oas_agent"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/wjessop/oas_agent"
  spec.metadata["changelog_uri"] = "https://github.com/wjessop/oas_agent/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "msgpack", "~> 1.6.0"

  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.0"
end
