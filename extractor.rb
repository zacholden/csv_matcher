# frozen_string_literal: true

# Pulls data from a CSV into the format expected by the matcher
# values is padded at with an empty array so that ids can begin at 1.
class Extractor
  attr_reader :values, :headers, :algo, :phones, :emails

  def initialize(algo)
    @algo = algo
    @headers = nil
    @values = [[]]
  end

  def extract(path)
    CSV.foreach(path, headers: true) do |row|
      @headers ||= row.headers
      phone_columns ||= @headers.filter do |header|
        algo.phone? && header.downcase.match?(algo.phone)
      end
      email_columns ||= @headers.filter do |header|
        algo.email? && header.downcase.match?(algo.email)
      end

      if algo.phone? && algo.email?
        phones = phone_columns.filter_map { |c| normalize_phone(row[c]) }
        emails = email_columns.filter_map { |c| normalize_email(row[c]) }
        @values << (phones + emails)
      elsif algo.phone?
        @values << phone_columns.filter_map { |c| normalize_phone(row[c]) }
      elsif algo.email?
        @values << email_columns.filter_map { |c| normalize_email(row[c]) }
      end
    end

    self
  end

  private

  def normalize_phone(phone)
    return nil if phone.to_s.strip.empty?

    digits_only = phone.gsub(/\D/, '')

    digits_only = digits_only[1..] if digits_only.length == 11 && digits_only[0] == '1'

    digits_only.length == 10 ? digits_only : nil
  end

  def normalize_email(email)
    return nil if email.to_s.strip.empty? || !email.match?('@')

    email.downcase
  end
end
