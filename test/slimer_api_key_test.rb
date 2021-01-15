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

  def test_generate
    new_api_key = Slimer::ApiKey.generate "hulk"
    assert_equal "hulk", new_api_key.name
    refute_empty new_api_key.token
  end

  def test_duplicate_token_generation_resolver
    existing_api_key = Slimer::ApiKey.create(token: "abc123")
    initial_api_key_count = Slimer::ApiKey.count
    random_mock = Minitest::Mock.new
    random_mock.expect :urlsafe_base64, "abc123"
    random_mock.expect :urlsafe_base64, "abc1234"

    Object.stub_const(:SecureRandom, random_mock) do
      new_api_key = Slimer::ApiKey.generate "hulk"
      assert_equal initial_api_key_count + 1, Slimer::ApiKey.count
      refute_empty new_api_key.token
      refute_equal new_api_key.token, existing_api_key.token
    end
  end
end
