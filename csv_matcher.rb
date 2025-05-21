# frozen_string_literal: true
require 'csv'
require_relative 'matching_type'

class CSVMatcher
  def self.call(path, matching_type, write: false)
    identifier = 0

    CSV.generate do |csv|
      CSV.foreach(path, headers: true) do |row|
        csv << row.headers.unshift('id') if identifier.zero?
        csv << matching_type.call(row, identifier)
        identifier += 1
      end
    end.tap { |csv| write && File.write("#{path.split('.').first}-matched.csv", csv) }
  end
end
