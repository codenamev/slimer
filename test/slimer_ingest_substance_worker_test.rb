# frozen_string_literal: true

require "test_helper"
require "sidekiq/testing"

class SlimerIngestSubstanceWorkerTest < Minitest::Test
  def setup
    Slimer.reset!
    Slimer.db
  end

  def test_only_payload
    initial_count = Slimer::Substance.count

    Sidekiq::Testing.inline! do
      Slimer::Workers::IngestSubstance.perform_async("{}")
      assert_equal initial_count + 1, Slimer::Substance.count
      assert_equal Slimer::DEFAULT_GROUP, Slimer::Substance.last.group
      refute_nil Slimer::Substance.last.uid
    end
  end

  def test_payload_with_group
    initial_count = Slimer::Substance.count

    Sidekiq::Testing.inline! do
      Slimer::Workers::IngestSubstance.perform_async("{}", "ruby")
      assert_equal initial_count + 1, Slimer::Substance.count
      assert_equal "ruby", Slimer::Substance.last.group
      refute_nil Slimer::Substance.last.uid
    end
  end

  def test_payload_with_metadata
    initial_count = Slimer::Substance.count
    metadata = { "tags" => ["logs"] }

    Sidekiq::Testing.inline! do
      Slimer::Workers::IngestSubstance.perform_async("{}", "ruby", metadata)
      assert_equal initial_count + 1, Slimer::Substance.count
      assert_equal "ruby", Slimer::Substance.last.group
      assert_equal metadata.transform_keys(&:to_s), Slimer::Substance.last.metadata
    end
  end
end
