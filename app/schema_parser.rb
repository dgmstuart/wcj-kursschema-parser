# frozen_string_literal: true

require "CSV"

class SchemaParser
  WEEK_HEADER = "Vecka"
  COURSES_HEADER = "Kurser       Lindy /Jazz"

  WEEKDAY_COLUMN_NUMBERS = (1...16)
  WEEKEND_COLUMN_NUMBERS = (16...22)

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
    Course.new(course_id:, week_data:, weekend_data:)
  end

  def course_data(data:, course_id:)
    [
      filtered_data(data:, column_numbers: WEEKDAY_COLUMN_NUMBERS, string: course_id),
      filtered_data(data:, column_numbers: WEEKEND_COLUMN_NUMBERS, string: course_id)
    ]
  end

  def filtered_data(data:, column_numbers:, string:)
    data.select do |row|
      row.fields[column_numbers].compact.any? do |value|
        if string == "A"
          value == string
        else
          value.include?(string)
        end
      end
    end
  end

  class Course
    def initialize(course_id:, week_data:, weekend_data:)
      @course_id = course_id
      @week_data = week_data
      @weekend_data = weekend_data
    end

    def weeknight_weeks
      week_numbers(@week_data)
    end

    def weekend_weeks
      week_numbers(@weekend_data)
    end

    def weeknight_dates
      dates(data: @week_data, column_numbers: WEEKDAY_COLUMN_NUMBERS)
    end

    def weekend_dates
      dates(data: @weekend_data, column_numbers: WEEKEND_COLUMN_NUMBERS)
    end

    private

    def dates(data:, column_numbers:)
      data.map do |row|
        weekend_fields = row.fields[column_numbers]
        weekend_fields.each_with_index.filter_map do |value, i|
          next unless value && value.include?(@course_id)

          group = i / 3
          date_index = group * 3
          weekend_fields[date_index].strip
        end
      end.flatten
    end

    def week_numbers(data)
      data.map { |row| Integer(row["Vecka"]) }
    end
  end
end
