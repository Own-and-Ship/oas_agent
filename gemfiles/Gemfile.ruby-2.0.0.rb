source "https://rubygems.org"

# Pin dependencies low enough for this ruby - Bundler 1 can't figure this out
gem "rake", "~> 12.0"
gem "msgpack", "~> 1.3.0"

gemspec path: "../"
