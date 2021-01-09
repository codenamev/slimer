# frozen_string_literal: true

require "test_helper"

class SlimerSubstanceTest < Minitest::Test
  def setup
    Slimer.reset!
  end

  # This test is here to simply verify a direct call to the model ensures a
  # connection to the database.
  def test_count
    assert Slimer::Substance.count.zero?
  end
end
