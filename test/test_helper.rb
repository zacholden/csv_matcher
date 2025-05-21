# frozen_string_literal: true
require 'minitest/autorun'
require 'csv'

# Add project root to the load path
$LOAD_PATH.unshift File.expand_path('../', __dir__)

# Require the project files
require_relative '../csv_matcher'
require_relative '../matching_type'

# Test data helper methods can be added here
def create_test_csv(filename, data)
  CSV.open(filename, 'w') do |csv|
    data.each { |row| csv << row }
  end
end

def delete_test_file(filename)
  File.delete(filename) if File.exist?(filename)
end
