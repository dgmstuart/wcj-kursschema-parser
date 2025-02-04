# frozen_string_literal: true

require "./app/schema_parser/date_parser"
require "CSV"

class SchemaParser
  WEEK_HEADER = "Vecka"
  COURSES_HEADER = "Kurser       Lindy /Jazz"

  NON_COURSE_STRINGS = [
    "Önskekurser",
    "Önske-kurser",
    "Öppet hus",
    "Registreringen stänger",
    "Första kursdag"
  ]

  WEEKDAY_COLUMN_NUMBERS = (1...16)
  WEEKEND_COLUMN_NUMBERS = (16...22)

  def parse(file_path)
    data = CSV.read(file_path, headers: true)

    sections = TermSections.new(data)
    builder = TermBuilder.new
    Terms.new(
      autumn: builder.build(data:, term_section: sections.autumn),
      spring: builder.build(data:, term_section: sections.spring),
    )
  end

  private

  Terms = Data.define(:autumn, :spring)
  Term = Data.define(:id, :year, :courses)

  class TermBuilder
    def build(data:, term_section:)
      Term.new(
        id: term_section.id,
        year: term_section.year,
        courses: term_courses(data:, term_section:)
      )
    end

    private

    def term_courses(data:, term_section:)
      term_rows = data[term_section.row_numbers]
      term_schedule_rows = term_rows.reject { |row| row[WEEK_HEADER].nil? }
      course_ids = CourseIdsParser.new.course_ids(term_rows)

      courses(course_ids:, schedule_data: term_schedule_rows, year: term_section.year)
    end

    def courses(course_ids:, schedule_data:, year:)
      course_ids.each_with_object({}) do |course_id, hash|
        hash[course_id] = Course.new(schedule_data:, course_id:, year:)
      end
    end
  end

  class CourseIdsParser
    def course_ids(data)
      data
        .reject { |row| not_a_course?(row[COURSES_HEADER]) }
        .map { |row| row[COURSES_HEADER] }
        .map { |course_id| remove_all_after_first_digit(course_id) }
    end

    private

    def not_a_course?(value)
      return true if value.nil?

      NON_COURSE_STRINGS.any?{ |string| value.include?(string) }
    end

    def remove_all_after_first_digit(string)
      string.gsub(/^([^0-9]*[0-9]).*/, '\1')
    end
  end

  class TermSections
    def initialize(data)
      @term_headers = TermHeadersBuilder.new.build(data)
      @autumn_term_header, @spring_term1_header, _spring_term2_header = @term_headers
    end

    def autumn
      build_section(term_header: @autumn_term_header, row_number_calculator: AutumnTermRowNumbersCalculator.new)
    end

    def spring
      build_section(term_header: @spring_term1_header, row_number_calculator: SpringTermRowNumbersCalculator.new)
    end

    private

    def build_section(term_header:, row_number_calculator:)
      TermSection.new(
        id: term_header.id,
        row_numbers: row_number_calculator.row_numbers(*@term_headers)
      )
    end
  end

  class AutumnTermRowNumbersCalculator
    def row_numbers(autumn_term, spring_term1, spring_term_2)
      first = autumn_term.row_index + 1
      last = spring_term1.row_index - 1
      (first..last)
    end
  end

  class SpringTermRowNumbersCalculator
    def row_numbers(autumn_term, spring_term1, spring_term_2)
      first = spring_term1.row_index + 1
      (first..)
    end
  end

  class TermHeadersBuilder
    TERM_ID_REGEX = /(HT|VT)\d+/

    def build(data)
      header_rows(data).map do |row, row_index|
        text = row.fields.find do |field|
          header_field?(field:)
        end

        TermHeader.new(id: text[TERM_ID_REGEX], row_index:)
      end
    end

    private

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

  TermSection = Data.define(:id, :row_numbers) do
    def year
      Integer("20" + id[/\d+/])
    end
  end

  TermHeader = Data.define(:id, :row_index)

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
