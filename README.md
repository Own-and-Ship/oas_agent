# OasAgent

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/oas_ruby_agent`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oas_agent'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oas_ruby_agent

## Usage

### Development server

In development an endpoint is automatically added to your application at `/oas`. When visited this shows you a list of deprecations that have occurred since the development server was started. If the mount point conflicts with any of your routes you can change it in your application's development config.

```ruby
YourApp::Application.configure do
  config.oas_dev_engine.mounted_path = "some_new_path"
end
```

By default the route is only added in development mode.

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

#### If you're running in test mode:

You will need the following config if you're running RSpec (minitest hasn't been tested yet):

    test:
      <<: *default_settings
      enabled: true
      reporter:
        send_immediately: true
        max_reports_to_batch: 1

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wjessop/oas_ruby_agent.
