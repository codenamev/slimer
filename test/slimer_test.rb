# frozen_string_literal: true

require "test_helper"

class SlimerTest < Minitest::Test
  def setup
    Slimer.reset!
  end

  def test_that_it_has_a_version_number
    refute_nil ::Slimer::VERSION
  end

  def test_options
    assert_equal Slimer::DEFAULTS, Slimer.options
  end

  def test_options_setter
    Slimer.options = { slug: "bogus" }
    expected_options = {
      slug: "bogus",
      groups: Set.new([ Slimer::DEFAULT_GROUP ]),
      database_url: Slimer::DEFAULT_DATABASE_URL
    }
    assert_equal expected_options, Slimer.options
  end

  def test_groups
    assert_equal Slimer::DEFAULTS[:groups], Slimer.groups
  end

  def test_groups_setter
    Slimer.groups = [:bogus, "awesome", "bogus"]
    assert_equal Set.new(["bogus", "awesome"]), Slimer.groups
  end

  def test_groups_nested_string_setter
    Slimer.group "ruby/parsers"
    assert_equal Set.new([Slimer::DEFAULT_GROUP, "ruby", "ruby/parsers"]), Slimer.groups
  end

  def test_groups_single_level_nested_setter
    Slimer.group :ruby do |config|
      config.group :parsers
    end
    assert_equal Set.new([Slimer::DEFAULT_GROUP, "ruby", "ruby/parsers"]), Slimer.groups
  end

  def test_configure
    Slimer.configure do |config|
      config.slug :bogus
      config.groups [:ruby, :rails, "ruby/parsers"]
    end
    assert_equal Set.new(["ruby", "rails", "ruby/parsers"]), Slimer.groups
  end

  def test_db
    require "sequel"

    database = Slimer.db
    assert_instance_of Sequel::SQLite::Database, database
  end
end
