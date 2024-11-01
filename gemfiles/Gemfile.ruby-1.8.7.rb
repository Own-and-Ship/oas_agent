source "https://rubygems.org"

# Pin dependencies low enough for this ruby - Bundler 1 can't figure this out
gem "rake", "~> 10.5.0"
gem "msgpack", "~> 0.6.2"
gem "json"

gemspec :path => "../"
