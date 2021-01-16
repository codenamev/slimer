# frozen_string_literal: true

require_relative "slimer/version"

require_relative "slimer/database"
require_relative "slimer/group_configurator"

require "logger"

# @abstract
module Slimer
  class Error < StandardError; end

  DEFAULT_GROUP = "general"
  DEFAULT_DATABASE_URL = "sqlite://./slimer.db"
  DEFAULT_SIDEKIQ_QUEUE = "slimer"

  DEFAULTS = {
    groups: Set.new([DEFAULT_GROUP]),
    database_url: DEFAULT_DATABASE_URL,
    sidekiq_queue: DEFAULT_SIDEKIQ_QUEUE
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

  def self.groups(new_groups = nil)
    self.groups = new_groups if new_groups
    options[:groups]
  end

  def self.groups=(new_groups = Set.new(options[:groups].dup))
    @options[:groups] = Set.new(new_groups.map(&:to_s))
  end

  def self.group(new_group, &block)
    options[:groups] += GroupConfigurator.group(new_group, &block).all
  end

  def self.database_url(db_url = nil)
    self.database_url = db_url if db_url
    options[:database_url]
  end

  def self.database_url=(db_url)
    @options[:database_url] = db_url
  end

  def self.sidekiq_queue(new_queue = nil)
    self.sidekiq_queue = new_queue if new_queue
    options[:sidekiq_queue]
  end

  def self.sidekiq_queue=(new_queue)
    @options[:sidekiq_queue] = new_queue
  end

  def self.configure
    yield self
  end

  def self.configure_sidekiq_client(&block)
    Sidekiq.configure_client(&block)
  end

  def self.configure_sidekiq_server(&block)
    Sidekiq.configure_server(&block)
  end

  def self.logger
    @logger ||= Logger.new($stdout, level: Logger::INFO)
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
    truncate_tables!
    @db = nil
  end

  def self.truncate_tables!
    Slimer::ApiKey.truncate if defined? Slimer::ApiKey
    Slimer::Substance.truncate if defined? Slimer::Substance
  end
end

# These all depend on Slimer.options to exist, so we'll load hem after our
# initial module is setup.
require_relative "slimer/workers"
