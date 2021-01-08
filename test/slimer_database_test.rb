# frozen_string_literal: true

require "test_helper"

class SlimerDatabaseTest < Minitest::Test
  def setup
    Slimer.reset!
  end

  def test_db_with_slimer_env
    require "sequel/core"

    test_db_url = "sqlite://./tmp/slimer_test.db"
    ENV["SLIMER_DATABASE_URL"] = test_db_url

    database = Slimer.db
    assert_equal test_db_url, Slimer.options[:database_url]
    assert_instance_of Sequel::SQLite::Database, database
  end

  def test_db_with_heroku_env
    test_db_url = "sqlite://./tmp/slimer_test2.db"
    ENV["DATABASE_URL"] = test_db_url

    database = Slimer.db
    assert_equal test_db_url, Slimer.options[:database_url]
    assert_instance_of Sequel::SQLite::Database, database
  end

  def test_db_connection_auto_migrates
    database = Slimer.db

    Slimer::Database::REQUIRED_TABLES.each do |t|
      assert database.table_exists?(t)
    end
  end
end
