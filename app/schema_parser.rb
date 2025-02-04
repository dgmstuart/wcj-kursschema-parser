# frozen_string_literal: true

require "./app/schema_parser/date_parser"
require "CSV"

class SchemaParser
  WEEK_HEADER = "Vecka"
  COURSES_HEADER = "Kurser       Lindy /Jazz"

  TERM_ID_REGEX = /(HT|VT)\d+/

  WEEKDAY_COLUMN_NUMBERS = (1...16)
  WEEKEND_COLUMN_NUMBERS = (16...22)

  YEAR = 2025 # TODO - parameterise or fetch from CSV

  def parse(file_path)

    data = CSV.foreach(file_path, headers: true)
    week_rows = data.reject { |row| row[WEEK_HEADER].nil? }
    spring_term_rows = week_rows.reject { |row| Integer(row[WEEK_HEADER]) > 25 }

    # NOTE: not always accurate to assume overlap with Spring term rows - sometimes course list overflows this.
    spring_course_ids = course_ids(spring_term_rows)

    courses(course_ids: spring_course_ids, period_data: spring_term_rows)
  end

  private

  Term = Data.define(:id, :row_index)

  def terms(data)
    header_rows(data).map do |row, row_index|
      text = row.fields.find do |field|
        header_field?(field:)
      end

      Term.new(id: text[TERM_ID_REGEX], row_index:)
    end
  end

  def header_rows(data)
    data.each_with_index.select do |row, index|
      row.fields.any? do |field|
        header_field?(field:)
      end
    end
  end

  def header_field?(field:)
    field && field.match?(/Stora.+#{TERM_ID_REGEX}/)
  end

  def course_ids(data)
    data
      .reject { |row| row[COURSES_HEADER].nil? }
      .reject { |row| row[COURSES_HEADER].include?("Önskekurser") }
      .map { |row| row[COURSES_HEADER] }
      .map { |course_id| remove_all_after_first_digit(course_id) }
  end

  def remove_all_after_first_digit(string)
    string.gsub(/^([^0-9]*[0-9]).*/, '\1')
  end

  def courses(course_ids:, period_data:)
    course_ids.each_with_object({}) do |course_id, hash|
      hash[course_id] = Course.new(period_data:, course_id:)
    end
  end

  class Course
    def initialize(
      course_id:,
      period_data:,
      date_parser: SchemaParser::DateParser.new
    )
      @course_id = course_id
      @period_data = period_data
      @date_parser = date_parser
    end

    def weeknight_weeks
      weeknight_dates.map(&:cweek)
    end

    def weekend_weeks
      weekend_dates.map(&:cweek).uniq
    end

    def weeknight_dates
      dates(column_numbers: WEEKDAY_COLUMN_NUMBERS)
    end

    def weekend_dates
      dates(column_numbers: WEEKEND_COLUMN_NUMBERS)
    end

    private

    def dates(column_numbers:)
      @period_data.map do |row|
        fields = row.fields[column_numbers]
        dates_from_fields(fields)
      end.flatten
    end

    def dates_from_fields(fields)
      fields.each_with_index.filter_map do |value, i|
        next unless matches_course_id?(value)

        group = i / 3
        date_index = group * 3
        @date_parser.parse(fields[date_index], year: YEAR)
      end
    end

    def matches_course_id?(value)
      return unless value

      if @course_id == "A"
        value == @course_id
      else
        value.include?(@course_id)
      end
    end
  end
end
