# frozen_string_literal: true

require "test_helper"

class SlimerApiKeyTest < Minitest::Test
  def setup
    Slimer.reset!
    Slimer.db
  end

  def test_count
    assert Slimer::ApiKey.count.zero?
  end
end
