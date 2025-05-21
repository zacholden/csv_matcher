# frozen_string_literal: true
class MatchingType
  attr_reader :name

  def initialize(name)
    @name = name
    @cache = {}
    @clauses = []
  end

  def match(column, as: nil, normalize: nil)
    @clauses << build_lambda(column, as: as, normalize: normalize)
    self
  end

  def call(row, identifier)
    unique_id = run_clauses(row, identifier) || identifier

    row.fields.unshift(unique_id)
  end

  private

  attr_accessor :clauses, :cache

  def run_clauses(row, identifier)
    current_result = false
    final_result = false
    i = 0

    loop do
      break if i >= clauses.length

      current_result = clauses[i].call(row, identifier)
      if current_result
        final_result = current_result
        identifier = current_result
      end

      i += 1
    end

    final_result || current_result
  end

  def build_lambda(column, as: nil, normalize: nil)
    cache_name = as || column
    @cache[cache_name] ||= {}

    lambda do |row, identifier|
      val = if normalize.nil?
              row[column]
            else
              normalize.call(row[column])
            end

      if cache[cache_name][val]
        cache[cache_name][val]
      else
        cache[cache_name][val] = identifier unless val.nil?
        false
      end
    end
  end
end
