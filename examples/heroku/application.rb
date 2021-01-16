# frozen_string_literal: true

require "pg"
require "slimer"

Slimer.logger = Logger.new("#{__dir__}/slimer.log")
Slimer.db
