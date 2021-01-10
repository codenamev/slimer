# frozen_string_literal: true

require "test_helper"

class SlimerSubstanceTest < Minitest::Test
  def setup
    Slimer.reset!
    Slimer.db
  end

  def test_count
    assert Slimer::Substance.count.zero?
  end
end
