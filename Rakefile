require "bundler/gem_tasks"
require "rake/testtask"
require "yaml"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

# Helper method to normalize Ruby version strings for service names
def normalize_version(version)
  version.gsub(".", "_").gsub("-", "_")
end

# Helper method to run docker-compose and capture the output, including build logs
def docker_compose_up(service_name, verbose: false)
  # Directing build output to a file
  build_log_file = "docker-build-#{service_name}.log"
  quiet = verbose ? "" : " > /dev/null"
  system("docker-compose up --build --exit-code-from #{service_name} #{service_name} 2>&1 | tee #{build_log_file}#{quiet}")
end

# Helper method to extract test results from container logs
def docker_compose_results(service_name)
  `docker-compose logs #{service_name} 2>&1`
end

# Helper method to stop and remove containers quietly
def docker_compose_down(service_name)
  system("docker-compose stop #{service_name} > /dev/null 2>&1")
  system("docker-compose rm -f #{service_name} > /dev/null 2>&1")
end

desc "Run tests across all Ruby versions in Docker"
task "test:all" do
  ruby_versions = [
    "1.9.3", "2.0", "2.1.10", "2.2.10", "2.3.8", "2.4.10", "2.5.9", "2.6", "2.7.5", "3.0", "3.1", "3.2", "3.3-rc"
  ]
  threads = []

  # Generate docker-compose.yml configuration
  services = ruby_versions.each_with_object({}) do |version, hash|
    normalized_name = "ruby_#{normalize_version(version)}"
    hash[normalized_name] = {
      "build" => {
        "context" => ".",
        "args" => {
          "RUBY_VERSION" => version
        }
      },
      "volumes" => [".:/usr/src/app"],
      "command" => "rake"
    }
  end

  # Write configuration to docker-compose.yml
  File.open("docker-compose.yml", "w") { |file| file.write({ "version" => "3.8", "services" => services }.to_yaml) }

  # Run tests in parallel
  ruby_versions.each do |version|
    threads << Thread.new do
      service_name = "ruby_#{normalize_version(version)}"
      docker_compose_up(service_name, verbose: ENV["VERBOSE"])
      output = docker_compose_results(service_name)

      if output.include?(", 0 failures, 0 errors")
        puts "Ruby #{version}: ✅ passed"
      else
        puts "Ruby #{version} ❌ failed, run this version using `rake \"test:one[#{version}]\"`"
      end

      docker_compose_down(service_name)
    end
  end

  # Wait for all threads to complete
  threads.each(&:join)
end

desc "Run tests for a single Ruby version in Docker"
task "test:one", [:version] do |t, args|
  version = args[:version] || ENV["VERSION"]
  raise ArgumentError, "You must specify a Ruby version." unless version
  service_name = "ruby_#{normalize_version(version)}"

  log = docker_compose_up(service_name, verbose: ENV["VERBOSE"])

  output = docker_compose_results(service_name)

  if output.include?(", 0 failures, 0 errors")
    puts "Ruby #{version}: ✅ passed"
  else
    puts "Ruby #{version} ❌ failed, run this version using `rake \"test:one[#{version}]\"`"
  end

  # Stop and remove the container
  docker_compose_down(service_name)
end

task :default => :test
