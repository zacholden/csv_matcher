# frozen_string_literal: true
require_relative 'test_helper'
require 'tempfile'

class CSVMatcherTest < Minitest::Test
  def setup
    @temp_dir = File.join(Dir.tmpdir, "csv_matcher_test_#{Time.now.to_i}")
    Dir.mkdir(@temp_dir) unless Dir.exist?(@temp_dir)

    @test_csv_path = File.join(@temp_dir, 'test_input.csv')
    @test_data = [
      ['FirstName', 'LastName', 'Email', 'Phone'],
      ['John', 'Doe', 'john@example.com', '555-1234'],
      ['Jane', 'Smith', 'jane@example.com', '555-5678'],
      ['John', 'Different', 'JOHN@EXAMPLE.COM', '555-9012'],
      ['Unique', 'Person', 'unique@example.com', '555-1234']
    ]
    create_test_csv(@test_csv_path, @test_data)

    @normalize_email = ->(email) { email.to_s.downcase }
  end

  def teardown
    File.delete(@test_csv_path) if File.exist?(@test_csv_path)

    matched_file = "#{@test_csv_path.split('.').first}-matched.csv"
    File.delete(matched_file) if File.exist?(matched_file)

    Dir.glob(File.join(@temp_dir, '*')).each do |file|
      File.delete(file) if File.exist?(file)
    end

    Dir.rmdir(@temp_dir) if Dir.exist?(@temp_dir)
  end

  def test_basic_csv_matching
    matching_type = MatchingType.new('Email')
                                .match('Email', normalize: @normalize_email)

    result = CSVMatcher.call(@test_csv_path, matching_type)

    assert_kind_of String, result

    lines = result.split("\n")

    assert_equal 'id,FirstName,LastName,Email,Phone', lines[0]

    rows = CSV.parse(result, headers: true)

    assert_equal @test_data.length - 1, rows.length

    assert_equal rows[0]['id'], rows[2]['id']

    refute_equal rows[0]['id'], rows[1]['id']
    refute_equal rows[0]['id'], rows[3]['id']
  end

  def test_phone_matching
    matching_type = MatchingType.new('Phone')
                                .match('Phone')

    result = CSVMatcher.call(@test_csv_path, matching_type)
    rows = CSV.parse(result, headers: true)

    assert_equal rows[0]['id'], rows[3]['id']

    refute_equal rows[0]['id'], rows[1]['id']
    refute_equal rows[0]['id'], rows[2]['id']
  end

  def test_multiple_criteria_matching
    matching_type = MatchingType.new('Email and Phone')
                                .match('Email', normalize: @normalize_email)
                                .match('Phone')

    result = CSVMatcher.call(@test_csv_path, matching_type)
    rows = CSV.parse(result, headers: true)

    assert_equal rows[0]['id'], rows[2]['id']

    assert_equal rows[0]['id'], rows[3]['id']

    refute_equal rows[0]['id'], rows[1]['id']
  end

  def test_write_option
    matching_type = MatchingType.new('Basic')
                                .match('FirstName')

    CSVMatcher.call(@test_csv_path, matching_type, write: true)

    output_path = "#{@test_csv_path.split('.').first}-matched.csv"
    assert File.exist?(output_path), 'Output file was not created'

    content = File.read(output_path)
    assert_match(/^id,FirstName,LastName,Email,Phone/, content)
  end

  def test_empty_csv
    empty_csv_path = File.join(@temp_dir, 'empty.csv')
    create_test_csv(empty_csv_path, [%w[FirstName LastName Email Phone]])

    matching_type = MatchingType.new('Empty Test')
                                .match('Email')

    result = CSVMatcher.call(empty_csv_path, matching_type)

    assert_kind_of String, result

    CSVMatcher.call(empty_csv_path, matching_type, write: true)

    output_path = "#{empty_csv_path.split('.').first}-matched.csv"
    assert File.exist?(output_path), 'Output file was not created for empty CSV'

    File.delete(empty_csv_path) if File.exist?(empty_csv_path)
    File.delete(output_path) if File.exist?(output_path)
  end

  def test_input1
    path = 'input1.csv'

    normalize_phone_north_america = lambda { |phone|
      digits_only = phone.to_s.gsub(/\D/, '')

      digits_only = digits_only[1..] if digits_only.length == 11 && digits_only.start_with?('1')

      digits_only.length == 10 ? digits_only : nil
    }

    matching_type = MatchingType.new('Phone').match('Phone', normalize: normalize_phone_north_america)

    parsed_output = CSVMatcher.call(path, matching_type).then { |str| CSV.parse(str) }

    # Same phone number matches despite the different format
    assert parsed_output[3][0] == parsed_output[6][0]
  end

  def test_intput2
    path = 'input2.csv'

    matching_type = MatchingType
      .new('Phone or Email')
      .match('Phone1', as: 'phone')
      .match('Phone2', as: 'phone')
      .match('Email1', as: 'email')
      .match('Email2', as: 'email')

    parsed_output = CSVMatcher.call(path, matching_type).then { |str| CSV.parse(str) }

    # Only one person does not share a phone number or an email
    assert parsed_output[1..].map(&:first).uniq.length == 2
  end
end
