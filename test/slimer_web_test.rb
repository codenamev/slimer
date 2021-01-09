# frozen_string_literal: true

require "test_helper"
require "slimer/web"
require "rake/test"

class SlimerWebTest < Minitest::Test
  def app
    Slimer::Web
  end

  def setup
    Slimer.reset!
    ENV["RACK_ENV"] = "test"
  end

  def test_status
    get "/slimer/status"
    assert_equal 200, last_response.status
  end
end
