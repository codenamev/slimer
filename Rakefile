# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

require_relative "lib/slimer"

# Since the Slimer tasks establish a DB connection, update the logger so that we
# don't pollute STDOUT with table checks.
Slimer.logger = Logger.new("#{Dir.pwd}/rake.log", level: Logger::WARN)

require_relative "lib/slimer/tasks"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]
