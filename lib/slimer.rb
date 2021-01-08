# frozen_string_literal: true

require_relative "slimer/version"

require_relative "slimer/group_configurator"

require "logger"

# @abstract
module Slimer
  class Error < StandardError; end

  DEFAULT_GROUP = "general"
  DEFAULT_SLUG = "slimer"

  DEFAULTS = {
    slug: DEFAULT_SLUG,
    groups: Set.new([DEFAULT_GROUP])
  }.freeze

  def self.options
    @options ||= DEFAULTS.dup
  end

  def self.options=(opts)
    @options = DEFAULTS.merge(opts)
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
    @logger ||= Logger.new(STDOUT, level: Logger::Info)
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
  end
end
