# frozen_string_literal: true

require "test_helper"
require "sidekiq/testing"

class SlimerSubstanceTest < Minitest::Test
  def setup
    Slimer.reset!
    Slimer.db
  end

  def test_count
    assert Slimer::Substance.count.zero?
  end

  def test_consume_min
    substance = { thing: "this" }
    initial_count = Slimer::Substance.count

    Sidekiq::Testing.inline! do
      Slimer::Substance.consume substance
      assert_equal initial_count + 1, Slimer::Substance.count
      assert_equal Slimer::DEFAULT_GROUP, Slimer::Substance.last.group
      assert_equal substance.transform_keys(&:to_s), Slimer::Substance.last.payload
    end
  end

  def test_consume_with_group
    substance = { thing: "this" }
    initial_count = Slimer::Substance.count

    Sidekiq::Testing.inline! do
      Slimer::Substance.consume substance, group: :ruby
      assert_equal initial_count + 1, Slimer::Substance.count
      assert_equal "ruby", Slimer::Substance.last.group
      assert_equal substance.transform_keys(&:to_s), Slimer::Substance.last.payload
    end
  end

  def test_consume_with_metadata
    substance = { thing: "this" }
    metadata = { tags: ["logs"] }
    initial_count = Slimer::Substance.count

    Sidekiq::Testing.inline! do
      Slimer::Substance.consume substance, metadata: metadata
      assert_equal initial_count + 1, Slimer::Substance.count
      assert_equal metadata.transform_keys(&:to_s), Slimer::Substance.last.metadata
      assert_equal substance.transform_keys(&:to_s), Slimer::Substance.last.payload
    end
  end
end
