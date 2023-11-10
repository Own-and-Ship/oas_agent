require "bundler/gem_tasks"
require "rake/testtask"
require "json"
require "yaml"

task :default => :test

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

SUPPORTED_RUBY_VERSIONS = [
  "1.9.3",
  "2.0", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7",
  "3.0", "3.1", "3.2", "3.3"
]

# desc "Run tests across all Ruby versions in Docker"
# task "test:all" => SUPPORTED_RUBY_VERSIONS.map { |version| "rv:test[#{version}]" }

task "docker-compose.yml": "Rakefile" do
  docker_compose_yml = {
    "version" => "3.8", # Docker engine 19.03.0+
    "services" => SUPPORTED_RUBY_VERSIONS.each_with_object({}) do |version, services|
      image_version = version == "3.3" ? "3.3-rc" : version
      gemfile = "gemfiles/Gemfile.ruby-#{version}.rb"
      services["ruby-#{version.gsub(".", "-")}"] = {
        build: {
          context: ".",
          dockerfile: "Dockerfile",
          args: {
            RUBY_VERSION: version,
            BUNDLE_GEMFILE: gemfile,
          }
        },
        volumes: [
          ".:/app",
        ],
        working_dir: "/app",
        environment: {
          BUNDLE_GEMFILE: "gemfiles/Gemfile.ruby-#{version}.rb"
        },
      }
    end
  }

  # Roundtripping through JSON turns symbol keys into strings
  File.write("docker-compose.yml", YAML.dump(JSON.parse(JSON.dump(docker_compose_yml))))
end

namespace :docker do
  task build: "docker-compose.yml"
  task :build, [:version] do |t, args|
    version = args[:version]
    raise ArgumentError, "You must specify a Ruby version." unless version

    sh "docker", "compose", "build", "ruby-#{version.gsub(".", "-")}"
  end

  task shell: :build
  task :shell, [:version] do |t, args|
    version = args[:version]
    raise ArgumentError, "You must specify a Ruby version." unless version

    sh "docker", "compose", "run", "ruby-#{version.gsub(".", "-")}", "bash"
  end

  task test: :build
  task :test, [:version] do |t, args|
    version = args[:version]
    raise ArgumentError, "You must specify a Ruby version." unless version

    Rake::Task["docker:build"].invoke(version)

    sh "docker", "compose", "run", "ruby-#{version.gsub(".", "-")}", "bundle", "exec", "rake", "test"
  end
end
