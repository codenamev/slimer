# frozen_string_literal: true

require "test_helper"
require "rake"

class SlimerRakeTest < Minitest::Test
  def setup
    Slimer.reset!
    Slimer.db
    @rake = Rake::Application.new
    Rake.application = @rake
  end

  def test_api_key_generator
    require "slimer/tasks"

    api_key_mock = Minitest::Mock.new
    api_key_mock.expect :token, "abc123"
    stdin_mock = Minitest::Mock.new
    stdin_mock.expect :gets, ""
    stdin_mock.expect :gets, "hulk"

    $stdin = stdin_mock

    output, _err = capture_io do
      Slimer::ApiKey.stub(:generate, api_key_mock) do
        @rake["slimer:api_keys:generate"].invoke
      end
    end

    $stdin = STDIN

    # rubocop:disable Layout/TrailingWhitespace
    expected_output = <<~OUTPUT
      Enter a name for this API key: 
      You must enter a name for this API key.
      Enter a name for this API key: 
      Your new Slimer API key for "hulk": abc123
    OUTPUT
    # rubocop:enable Layout/TrailingWhitespace
    assert_equal expected_output, output
    assert stdin_mock.verify
  end
end
