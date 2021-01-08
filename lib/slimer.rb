# frozen_string_literal: true

require_relative "slimer/version"

require_relative "slimer/database"
require_relative "slimer/group_configurator"

require "logger"

# @abstract
module Slimer
  class Error < StandardError; end

  DEFAULT_GROUP = "general"
  DEFAULT_SLUG = "slimer"
  DEFAULT_DATABASE_URL = "sqlite://./slimer.db"

  DEFAULTS = {
    slug: DEFAULT_SLUG,
    groups: Set.new([DEFAULT_GROUP]),
    database_url: DEFAULT_DATABASE_URL
  }.freeze

  def self.options
    @options ||= DEFAULTS.dup
  end

  def self.options=(opts)
    @options = DEFAULTS.merge(opts)
  end

  def self.db
    database_url_from_env = ENV.delete("SLIMER_DATABASE_URL") || ENV.delete("DATABASE_URL")

    if database_url_from_env
      @options[:database_url] = database_url_from_env
      return @db = Database.connection(
        options[:database_url] || DEFAULT_DATABASE_URL
      )
    end

    @db ||= Database.connection(
      options[:database_url] || DEFAULT_DATABASE_URL
    )
  end

  def self.slug(new_slug = DEFAULT_SLUG)
    return @slug unless new_slug

    @slug = new_slug
  end

  def self.groups(new_groups = nil)
    self.groups = new_groups if new_groups
    @groups
  end

  def self.groups=(new_groups = Set.new(options[:groups].dup))
    @groups = Set.new(new_groups.map(&:to_s))
  end

  def self.group(new_group, &block)
    @groups += GroupConfigurator.group(new_group, &block).all
  end

  def self.configure
    yield self
  end

  def self.logger
    @logger ||= Logger.new(STDOUT, level: Logger::INFO)
  end

  def self.logger=(logger)
    if logger.nil?
      self.logger.level = Logger::FATAL
      return self.logger
    end

    @logger = logger
  end

  def self.reset!
    @options = DEFAULTS.dup
    @groups = DEFAULTS[:groups].dup
    @db = nil
  end
end
