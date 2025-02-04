# frozen_string_literal: true

require "./app/schema_parser/date_parser"
require "CSV"

class SchemaParser
  WEEK_HEADER = "Vecka"
  COURSES_HEADER = "Kurser       Lindy /Jazz"

  NON_COURSE_STRINGS = ["Önskekurser", "Öppet hus", "Registreringen stänger", "Första kursdag"]

  WEEKDAY_COLUMN_NUMBERS = (1...16)
  WEEKEND_COLUMN_NUMBERS = (16...22)

  def parse(file_path)
    data = CSV.read(file_path, headers: true)

    _autumn_term, spring_term = TermsBuilder.new.build(data)

    term_courses(data:, term: spring_term)
  end

  private

  def term_courses(data:, term:)
    term_rows = data[term.row_numbers]
    term_schedule_rows = term_rows.reject { |row| row[WEEK_HEADER].nil? }
    course_ids = course_ids(term_rows)

    courses(course_ids:, schedule_data: term_schedule_rows, year: term.year)
  end

  class AutumnTerm
    def initialize(autumn_term:, spring_term1:)
      @autumn_term = autumn_term
      @spring_term1 = spring_term1
    end

    def year
      @autumn_term.year
    end

    def row_numbers
      first = @autumn_term.row_index + 1
      last = @spring_term1.row_index - 1
      (first..last)
    end
  end

  class SpringTerm
    def initialize(spring_term1:)
      @spring_term1 = spring_term1
    end

    def year
      @spring_term1.year
    end

    def row_numbers
      first = @spring_term1.row_index + 1
      (first..)
    end
  end

  class TermsBuilder
    TERM_ID_REGEX = /(HT|VT)\d+/

    def build(data)
      autumn_term, spring_term1, _spring_term2 = build_info(data)
      [
        AutumnTerm.new(autumn_term:, spring_term1:),
        SpringTerm.new(spring_term1:)
      ]
    end

    private

    def build_info(data)
      header_rows(data).map do |row, row_index|
        text = row.fields.find do |field|
          header_field?(field:)
        end

        TermInfo.new(id: text[TERM_ID_REGEX], row_index:)
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
  end

  TermInfo = Data.define(:id, :row_index) do
    def year
      Integer("20" + id[/\d+/])
    end
  end

  def course_ids(data)
    data
      .reject { |row| not_a_course?(row[COURSES_HEADER]) }
      .map { |row| row[COURSES_HEADER] }
      .map { |course_id| remove_all_after_first_digit(course_id) }
  end

  def not_a_course?(value)
    return true if value.nil?

    NON_COURSE_STRINGS.any?{ |string| value.include?(string) }
  end

  def remove_all_after_first_digit(string)
    string.gsub(/^([^0-9]*[0-9]).*/, '\1')
  end

  def courses(course_ids:, schedule_data:, year:)
    course_ids.each_with_object({}) do |course_id, hash|
      hash[course_id] = Course.new(schedule_data:, course_id:, year:)
    end
  end

  class Course
    def initialize(
      course_id:,
      schedule_data:,
      year:,
      date_parser: SchemaParser::DateParser.new
    )
      @course_id = course_id
      @schedule_data = schedule_data
      @year = year
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
      @schedule_data.map do |row|
        fields = row.fields[column_numbers]
        dates_from_fields(fields)
      end.flatten
    end

    def dates_from_fields(fields)
      fields.each_with_index.filter_map do |value, i|
        next unless matches_course_id?(value)

        group = i / 3
        date_index = group * 3
        @date_parser.parse(fields[date_index], year: @year)
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
