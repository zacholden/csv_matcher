# frozen_string_literal: true

# Responsible for writing a CSV once we have the map of
# matched rows
class CSVWriter
  def self.call(path, matched_rows, headers, write: true)
    CSV.generate do |csv|
      csv << headers.unshift('id')
      CSV.foreach(path).with_index do |row, idx|
        next if idx.zero?

        id = matched_rows.fetch(idx, idx)
        csv << row.unshift(id)
      end
    end.tap { |csv| write && File.write("#{path.split('.').first}-matched.csv", csv) }
  end
end
