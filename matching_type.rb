# frozen_string_literal: true

# Matches values by their index. Returns a hash of
# integer keys to the index that owns them
class MatchingType
  def self.match(values)
    matches = Hash.new { |hash, key| hash[key] = [] }

    values.each_with_index do |arr, idx|
      arr.each do |val|
        matches[val] << idx
      end
    end

    matches.values.each_with_object({}) do |arr, acc|
      owner = arr.filter_map { |v| acc[v] }.min || arr.first

      arr.each { |i| acc[i] = owner unless i == owner }
    end
  end
end
