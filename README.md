# OasAgent

This is the Ruby agent library for the Own & Ship service, for more information see [ownandship.io](https://ownandship.io).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oas_agent'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oas_agent

## Usage

### Advanced config options:

    # The reporter aggregates reports from the app and sends them to the Own & Ship
    # service over the Internet.
    reporter:
      # How many reports from the application should we queue waiting for the
      # reporter being reported. About 1000 per thread should be adequate. The
      # agent will report if the queue overflows and it may need to be increased
      # if that happens.
      max_reports_to_queue: 5000

      # How many reports to send in one batch to the Own & Ship service. Leaving
      # at 100 is ideal for most situations
      max_reports_to_batch: 100

      # How long (in seconds) after receiving a report should we wait to fill the
      # max_reports_to_batch buffer before just sending what we have, even if that
      # is less than max_reports_to_batch.
      batched_report_timeout: 10

      # Wether to send the report immediately, or queue it for sending in the
      # background thread. You likely never want to set this except in test mode
      # as at least RSpec doesn't leave the reporter thread alive long enough
      # to send the reports.
      send_immediately: true

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Ruby versions

We target Ruby 1.9.3 or newer, and run CI against every minor release of ruby since then to ensure compatibility.

The development environment is pinned in `.ruby-version` so we can run development tooling on a more modern version of Ruby, but the library code and dependencies must be compatible with 1.9.3.

The test suite is powered by [minitest](https://github.com/minitest/minitest), you can run the entire suite with `rake test` or run a single test file with `ruby -Itest test/lib/agent/ruby_receiver_test.rb`.

### Testing ye olde Ruby versions in Docker

You can test old versions of Ruby locally as long as you have Docker installed. To test all versions this library supports you can run:

    rake test:all

You will get an output something like this:

    Ruby 2.3.8 ❌ failed, run this version using `rake "docker:test[2.3.8]"`
    Ruby 1.9.3 ❌ failed, run this version using `rake "docker:test[1.9.3]"`
    Ruby 2.2.10 ❌ failed, run this version using `rake "docker:test[2.2.10]"`
    Ruby 2.4.10 ❌ failed, run this version using `rake "docker:test[2.4.10]"`
    Ruby 3.0: ✅ passed
    Ruby 3.1: ✅ passed
    Ruby 2.7.5: ✅ passed
    Ruby 3.2: ✅ passed
    Ruby 3.3-rc: ✅ passed
    Ruby 2.6: ✅ passed
    Ruby 2.5.9: ✅ passed
    Ruby 2.1.10 ❌ failed, run this version using `rake "docker:test[2.1.10]"`
    Ruby 2.0 ❌ failed, run this version using `rake "docker:test[2.0]"`

Where a version fails you will be given a command to run the tests for that specific version:

    rake "docker:test[2.4.10]"
    or…
    VERSION=2.4.10 rake docker:test

This will give you the test suite output too so you can see what failed. If you need to diagnose Docker/build issues then pass VERBOSE to get the docker build output:

    VERBOSE=1 rake "docker:test[2.4.10]"

If you need to further diagnose Docker build issues you can build a docker image for the version you're interested in directly: (convert . to - in the version number.)

    docker compose build ruby-2-4-10

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/wjessop/oas_ruby_agent>.
