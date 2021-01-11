# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "slimer"

require "minitest/autorun"

Slimer.logger = Logger.new("#{Dir.pwd}/test_db.log", level: Logger::INFO)
