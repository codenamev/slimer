# frozen_string_literal: true

require "test_helper"
require "slimer/web"
require "rack/test"
require "sidekiq/testing"

class SlimerWebTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Slimer::Web
  end

  def setup
    ENV["RACK_ENV"] = "test"
    Slimer.reset!
    Slimer::Web.middlewares.clear
  end

  def test_configure_via_set
    app.set(:session_secret, "foo")
    assert_equal "foo", app.session_secret
  end

  def test_status
    get "/status"
    assert_equal 200, last_response.status
  end

  def test_consume_get_with_invalid_api_key
    get "/blah/consume?thing=this"
    assert_equal 403, last_response.status
  end

  def test_consume_post_with_invalid_api_key
    post "/blah/consume", "thing" => "this"
    assert_equal 403, last_response.status
  end

  def test_consume_get_with_api_key
    api_key = Slimer::ApiKey.generate("hulk")

    Sidekiq::Testing.inline! do
      get "/#{api_key.token}/consume?thing=this"
    end

    assert_equal 200, last_response.status
    assert_equal({ "thing" => "this" }, Slimer::Substance.last.payload)
  end

  def test_consume_post_with_api_key
    api_key = Slimer::ApiKey.generate("hulk")

    Sidekiq::Testing.inline! do
      post "/#{api_key.token}/consume", "thing" => "this"
    end

    assert_equal 200, last_response.status
    assert_equal({ "thing" => "this" }, Slimer::Substance.last.payload)
  end

  def test_consume_get_with_group
    api_key = Slimer::ApiKey.generate("hulk")

    Sidekiq::Testing.inline! do
      get "/#{api_key.token}/ruby/consume?thing=this"
    end

    assert_equal 200, last_response.status
    assert_equal({ "thing" => "this" }, Slimer::Substance.last.payload)
    assert_equal "ruby", Slimer::Substance.last.group
  end

  def test_consume_post_with_group
    api_key = Slimer::ApiKey.generate("hulk")

    Sidekiq::Testing.inline! do
      post "/#{api_key.token}/ruby/consume?thing=this"
    end

    assert_equal 200, last_response.status
    assert_equal({ "thing" => "this" }, Slimer::Substance.last.payload)
    assert_equal "ruby", Slimer::Substance.last.group
  end
end
