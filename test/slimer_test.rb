# frozen_string_literal: true

require "test_helper"
require "minitest/stub_const"

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
    expected_options = {
      groups: Set.new([Slimer::DEFAULT_GROUP]),
      database_url: Slimer::DEFAULT_DATABASE_URL,
      sidekiq_queue: Slimer::DEFAULT_SIDEKIQ_QUEUE
    }
    assert_equal expected_options, Slimer.options
  end

  def test_groups
    assert_equal Slimer::DEFAULTS[:groups], Slimer.groups
  end

  def test_groups_setter
    Slimer.groups = [:bogus, "awesome", "bogus"]
    assert_equal Set.new(%w[bogus awesome]), Slimer.groups
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
      config.groups [:ruby, :rails, "ruby/parsers"]
    end
    assert_equal Set.new(["ruby", "rails", "ruby/parsers"]), Slimer.groups
  end

  def test_db
    require "sequel"

    database = Slimer.db
    assert_instance_of Sequel::SQLite::Database, database
  end

  def test_configure_sidekiq_client
    mock = Minitest::Mock.new
    mock.expect(:configure_client, proc {}) # rubocop:disable Lint/EmptyBlock
    Slimer.stub_const(:Sidekiq, mock) do
      Slimer.configure(&:configure_sidekiq_client)
    end
    assert mock.verify
  end

  def test_configure_sidekiq_server
    mock = Minitest::Mock.new
    mock.expect(:configure_server, proc {}) # rubocop:disable Lint/EmptyBlock
    Slimer.stub_const(:Sidekiq, mock) do
      Slimer.configure(&:configure_sidekiq_server)
    end
    assert mock.verify
  end
end
