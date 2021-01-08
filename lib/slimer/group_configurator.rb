# frozen_string_literal: true

# A simple utility class to parse nested groups
class GroupConfigurator
  attr_reader :groups

  alias all groups

  # Creates a flat set of groups from a string or block
  #
  # @examples
  #
  # GroupConfigurator.group("ruby/rails") => #<Set: {[ "ruby", "ruby/rails" ]} >
  # GroupConfigurator.group(:ruby) do |config|
  #   config.group :rails
  # end => #<Set: {[ "ruby", "ruby/rails" ]} >
  def self.group(new_groups, &block)
    new.group(new_groups, &block)
  end

  # Creates a flat set of groups from a string or block
  #
  # @examples
  #
  # GroupConfigurator.group("ruby/rails") => #<Set: {[ "ruby", "ruby/rails" ]} >
  # GroupConfigurator.group(:ruby) do |config|
  #   config.group :rails
  # end => #<Set: {[ "ruby", "ruby/rails" ]} >
  def group(new_group)
    @groups ||= Set.new
    return group(group_from_string(new_group)) if new_group.to_s.include?("/")

    group_with_level = [@level, new_group].compact.join("/")
    @groups << group_with_level
    return self unless block_given?

    @level = group_with_level

    yield(self)
    self
  end

  private

  # Extracts nested groups from a string and sets new level as parent group
  #   e.g. group_from_string("ruby/rails")
  def group_from_string(new_group)
    new_groups = new_group.split("/")
    @groups << new_groups[0]
    @level = new_groups.shift
    new_groups
  end
end
