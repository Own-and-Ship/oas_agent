# encoding: utf-8
# frozen_string_literal: true

# This file must work on Ruby 1.9.3, sorry.

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "json"
require "yaml"

task :default => :spec

RSpec::Core::RakeTask.new(:spec)

# Backwards compatibility, we used to have a `test` task
task :test => :spec

SUPPORTED_RUBY_VERSIONS = [
  "1.8.7", "1.9.3", "2.0.0",
  "2.1.10", "2.2.10", "2.3.8", "2.4.10", "2.5.9", "2.6.10", "2.7.8",
  "3.0.7", "3.1.6", "3.2.5", "3.3.6", "3.4.1"
]

desc "Build all ruby version Docker images"
multitask "build:all" => SUPPORTED_RUBY_VERSIONS.map { |version| "docker:build_ruby_#{version}" }

desc "Exec command across all Ruby versions in Docker"
multitask "exec:all", [:command] => SUPPORTED_RUBY_VERSIONS.map { |version| "docker:exec_ruby_#{version}" }

desc "Run tests across all Ruby versions in Docker"
task "test:all" do
  require "thread"
  require "open3"

  # Run tests in parallel
  threads = SUPPORTED_RUBY_VERSIONS.map do |version|
    Thread.new do
      output, status = Open3.capture2e("docker", "compose", "run", "ruby-#{version.gsub(".", "-")}", "bundle", "exec", "rake", "spec")
      if status.success? && output.include?(", 0 failures, 0 errors")
        puts "Ruby #{version}: ✅ passed"
      else
        puts %{Ruby #{version} ❌ failed, run this version using `rake "docker:test[#{version}]"`}
      end
    end
  end

  # Wait for all threads to complete
  threads.each(&:join)
end

task "docker-compose.yml" => "Rakefile" do
  docker_compose_yml = {
    "services" => SUPPORTED_RUBY_VERSIONS.each_with_object({}) do |version, services|
      gemfile = case version
      when "1.8.7", "1.9.3", "2.0.0"
        "gemfiles/Gemfile.ruby-#{version}.rb"
     else
        "gemfiles/Gemfile.ruby-#{version.split(".").first(2).join(".")}.rb"
      end
      base_image = case version
      when "1.8.7"
        "ghcr.io/rspec/docker-ci:1.8.7"
      else
        "ruby:#{version}"
      end
      services["ruby-#{version.gsub(".", "-")}"] = {
        "build" => {
          "context" => ".",
          "dockerfile" => "Dockerfile",
          "args" => {
            "RUBY_BASE_IMAGE" => base_image,
            "BUNDLE_GEMFILE" => gemfile,
          }
        },
        "volumes" => [
          ".:/app",
        ],
        "working_dir" => "/app",
      }
    end
  }

  File.open("docker-compose.yml", "w+") do |file|
    file.puts "# This file is generated by `rake docker-compose.yml`"
    file.write(YAML.dump(docker_compose_yml))
  end
end

namespace :docker do
  # Depending on tasks with variables is basically impossible, so we define "internal" tasks
  # with the ruby version in the name of the task.
  SUPPORTED_RUBY_VERSIONS.each do |version|
    service = "ruby-#{version.gsub(".", "-")}"

    desc "Build docker image for Ruby #{version}"
    task "build_ruby_#{version}" => "docker-compose.yml" do
      sh "docker", "compose", "build", service
    end

    desc "Execute an arbitrary command in docker image for Ruby #{version}"
    task "exec_ruby_#{version}", [:command] => "docker-compose.yml" do |t, args|
      sh "docker", "compose", "run", "--rm", service, *Shellwords.shellsplit(args[:command])
    end

    desc "Open a shell in the docker image for Ruby #{version}"
    task "shell_ruby_#{version}" => "build_ruby_#{version}" do
      sh "docker", "compose", "run", "--rm", service, "bash"
    end

    desc "Run tests in the docker image for Ruby #{version}"
    task "test_ruby_#{version}" => "build_ruby_#{version}" do
      sh "docker", "compose", "run", "--rm", service, "bundle", "exec", "rake", "spec"
    end

    # Shorthand for Ruby 2.1+ (eg, `rake docker:build_ruby_2.1` -> `rake docker:build_ruby_2.1.10`)
    if version != "1.8.7" && version != "1.9.3" && version != "2.0.0"
      short_version = version.split(".").first(2).join(".")

      desc "Build docker image for Ruby #{version}"
      task "build_ruby_#{short_version}" => "build_ruby_#{version}"

      desc "Open a shell in the docker image for Ruby #{version}"
      task "shell_ruby_#{short_version}" => "shell_ruby_#{version}"

      desc "Run tests in the docker image for Ruby #{version}"
      task "test_ruby_#{short_version}" => "test_ruby_#{version}"
    end
  end

  # Then we define "public" tasks that call the internal tasks based on variable argument
  desc "Build docker image for given ruby version"
  task :build, [:version] do |t, args|
    version = args[:version] || ENV["VERSION"]
    versioned_task_name = "docker:build_ruby_#{args[:version]}"
    raise ArgumentError, "You must specify a supported Ruby version. Available versions: #{SUPPORTED_RUBY_VERSIONS.join(", ")}" unless Rake::Task.task_defined?(versioned_task_name)

    Rake::Task[versioned_task_name].invoke
  end

  desc "Open a shell in the docker image for given ruby version"
  task :shell, [:version] do |t, args|
    version = args[:version] || ENV["VERSION"]
    versioned_task_name = "docker:shell_ruby_#{args[:version]}"
    raise ArgumentError, "You must specify a supported Ruby version. Available versions: #{SUPPORTED_RUBY_VERSIONS.join(", ")}" unless Rake::Task.task_defined?(versioned_task_name)

    Rake::Task[versioned_task_name].invoke
  end

  desc "Run tests in the docker image for given ruby version"
  task :test, [:version] do |t, args|
    version = args[:version] || ENV["VERSION"]
    versioned_task_name = "docker:test_ruby_#{args[:version]}"
    raise ArgumentError, "You must specify a supported Ruby version. Available versions: #{SUPPORTED_RUBY_VERSIONS.join(", ")}" unless Rake::Task.task_defined?(versioned_task_name)

    Rake::Task[versioned_task_name].invoke
  end
end
