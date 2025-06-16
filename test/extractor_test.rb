# frozen_string_literal: true

require_relative 'test_helper'

class ExtractorTest < Minitest::Test
  def test_phone_extraction
    algo = Algo.new(['phone'])
    extraction = Extractor.new(algo).extract('input1.csv')

    assert extraction.values == [[], ['5551234567'], ['5551234567'], ['4441234567'], ['4567890123'], ['5556549873'],
                                 ['4441234567'], [], []]
  end
end
