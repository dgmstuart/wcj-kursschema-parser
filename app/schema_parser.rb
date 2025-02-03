# frozen_string_literal: true

require "CSV"

class SchemaParser
  WEEK_HEADER = "Vecka"
  COURSES_HEADER = "Kurser       Lindy /Jazz"

  def parse(file_path)

    data = CSV.foreach(file_path, headers: true)
    week_rows = data.reject { |row| row[WEEK_HEADER].nil? }
    spring_term_rows = week_rows.reject { |row| Integer(row[WEEK_HEADER]) > 25 }

    # NOTE: not always accurate to assume overlap with Spring term rows - sometimes course list overflows this.
    spring_course_ids = course_ids(spring_term_rows)

    spring_course_ids.each_with_object({}) do |course_id, hash|
      hash[course_id] = course(data: spring_term_rows, course_id:)
    end
  end

  private

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

  def course(data:, course_id:)
    week_data, weekend_data = course_data(data:, course_id:)
    Course.new(week_data:, weekend_data:)
  end

  def course_data(data:, course_id:)
    weekday_column_numbers = (0...16)
    weekend_column_numbers = (16...22)

    [
      filtered_data(data:, column_numbers: weekday_column_numbers, string: course_id),
      filtered_data(data:, column_numbers: weekend_column_numbers, string: course_id)
    ]
  end

  def filtered_data(data:, column_numbers:, string:)
    data.select do |row|
      row.fields[column_numbers].compact.any? { |value| value.include?(string) }
    end
  end

  class Course
    def initialize(week_data:, weekend_data:)
      @week_data = week_data
      @weekend_data = weekend_data
    end

    def weeknight_weeks
      week_numbers(@week_data)
    end

    def weekend_weeks
      week_numbers(@weekend_data)
    end

    private

    def week_numbers(data)
      data.map { |row| Integer(row["Vecka"]) }
    end
  end
end
