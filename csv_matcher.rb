# frozen_string_literal: true

require 'csv'
require_relative 'algo'
require_relative 'csv_writer'
require_relative 'extractor'
require_relative 'matching_type'
require_relative 'parser'

# Entry point for program. Creates a CSV with an id
# prepended to each row that indicates a grouping.
class CSVMatcher
  def self.call(path, algorithm, write: true)
    algo = Algo.new(algorithm)

    extracted = Extractor.new(algo).extract(path)

    matched_rows = MatchingType.match(extracted.values)

    CSVWriter.call(path, matched_rows, extracted.headers)
  end
end

options = Parser.parse(ARGV)
if options.error
  puts options.error
elsif options.file.nil?
  puts 'no file'
else
  CSVMatcher.call(options.file, options.algo, write: options.write)
  puts "CSV matched into #{options.file.split('.').first}-matched.csv"
end
