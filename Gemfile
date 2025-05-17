source "https://rubygems.org"

ruby file: ".ruby-version"

# Specify your gem's dependencies in oas_ruby_agent.gemspec
gemspec

# All other dependencies need to work with the earliest supported ruby
# (vurrently 1.9.3) up to head as they are installed as part of the test run,
# except rubocop which only needs to work on the version from .ruby-version as
# that's the only version we do linting in, to do linting in other versions
# would be redundant.
group :lint do
  gem "rubocop"
end
