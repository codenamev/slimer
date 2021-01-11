# frozen_string_literal: true

require "test_helper"
require "sidekiq/testing"

class SlimerIngestSubstanceWorkerTest < Minitest::Test
  def setup
    Slimer.reset!
    Slimer.db
  end

  # This test is here to simply verify a direct call to the model ensures a
  # connection to the database.
  def test_count
    initial_count = Slimer::Substance.count

    Sidekiq::Testing.inline! do
      Slimer::Workers::IngestSubstance.perform_async("{}")
      assert_equal initial_count + 1, Slimer::Substance.count
    end
  end
end
