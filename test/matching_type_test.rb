# frozen_string_literal: true

require_relative 'test_helper'

class MatchingTypeTest < Minitest::Test
  def test_simple_matching
    values = [['dave@gmail.com'], ['dave@gmail.com']]

    assert MatchingType.match(values) == { 1 => 0 }
  end
end
