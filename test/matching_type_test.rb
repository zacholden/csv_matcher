# frozen_string_literal: true
require_relative 'test_helper'

class MatchingTypeTest < Minitest::Test
  def setup
    @simple_matching_type = MatchingType.new('Simple')

    @normalize_email = ->(email) { email.to_s.downcase }

    @email_matching_type = MatchingType.new('Email')
                                       .match('Email', normalize: @normalize_email)
  end

  def test_initialization
    assert_equal 'Simple', @simple_matching_type.name
  end

  def test_match_method_returns_self
    result = @simple_matching_type.match('Column')
    assert_equal @simple_matching_type, result
  end

  def test_simple_matching
    row1 = { 'ID' => '1', 'Column' => 'same_value' }
    row2 = { 'ID' => '2', 'Column' => 'same_value' }
    row3 = { 'ID' => '3', 'Column' => 'different_value' }

    csv_row1 = CSV::Row.new(%w[ID Column], %w[1 same_value])
    csv_row2 = CSV::Row.new(%w[ID Column], %w[2 same_value])
    csv_row3 = CSV::Row.new(%w[ID Column], %w[3 different_value])

    matching = MatchingType.new('Test').match('Column')

    result1 = matching.call(csv_row1, 100)
    assert_equal 100, result1.first

    result2 = matching.call(csv_row2, 200)
    assert_equal 100, result2.first

    result3 = matching.call(csv_row3, 300)
    assert_equal 300, result3.first
  end

  def test_matching_with_normalization
    csv_row1 = CSV::Row.new(['Email'], ['User@Example.com'])
    csv_row2 = CSV::Row.new(['Email'], ['user@example.com'])

    result1 = @email_matching_type.call(csv_row1, 100)
    assert_equal 100, result1.first

    result2 = @email_matching_type.call(csv_row2, 200)
    assert_equal 100, result2.first
  end

  def test_matching_with_alias
    matching = MatchingType.new('Alias Test').match('OriginalColumn', as: 'aliased_name')

    csv_row1 = CSV::Row.new(['OriginalColumn'], ['test_value'])
    csv_row2 = CSV::Row.new(['OriginalColumn'], ['test_value'])

    result1 = matching.call(csv_row1, 100)
    assert_equal 100, result1.first

    result2 = matching.call(csv_row2, 200)
    assert_equal 100, result2.first
  end

  def test_multiple_match_conditions
    matching = MatchingType.new('Multiple')
                           .match('Email', normalize: @normalize_email)
                           .match('Phone')

    csv_row1 = CSV::Row.new(%w[Email Phone], ['user@example.com', '555-1234'])
    csv_row2 = CSV::Row.new(%w[Email Phone], ['USER@EXAMPLE.COM', '999-9999']) # Email matches after normalization
    csv_row3 = CSV::Row.new(%w[Email Phone], ['other@example.com', '555-1234']) # Phone matches
    csv_row4 = CSV::Row.new(%w[Email Phone], ['unique@example.com', '111-1111']) # Nothing matches

    result1 = matching.call(csv_row1, 100)
    result2 = matching.call(csv_row2, 200)
    result3 = matching.call(csv_row3, 300)
    result4 = matching.call(csv_row4, 400)

    assert_equal 100, result1.first
    assert_equal 100, result2.first
    assert_equal 100, result3.first
    assert_equal 400, result4.first
  end

  def test_nil_values_dont_match
    matching = MatchingType.new('Nil Test').match('Column')

    csv_row1 = CSV::Row.new(['Column'], [nil])
    csv_row2 = CSV::Row.new(['Column'], [nil])

    result1 = matching.call(csv_row1, 100)
    result2 = matching.call(csv_row2, 200)

    assert_equal 100, result1.first
    assert_equal 200, result2.first
  end
end
