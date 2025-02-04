# frozen_string_literal: true

require "date"

class SchemaParser
  class DateParser
    MONTH_STRINGS = {
      "jan." => 1,
      "feb." => 2,
      "mars" => 3,
      "apr." => 4,
      "april" => 4,
      "maj" => 5,
      "juni" => 6,
      "juli" => 7,
      "aug." => 8,
      "sep." => 9,
      "okt." => 10,
      "nov." => 11,
      "dec." => 12,
    }

    def parse(swedish_date_string, year:)
      day, month_string = swedish_date_string.split
      month = MONTH_STRINGS.fetch(month_string)

      Date.new(year, month, day.to_i)
    end
  end
end
