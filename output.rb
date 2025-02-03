#!/usr/bin/env ruby

require "./app/schema_parser"

file_path = "spec/fixtures/Schema kurser HT24-VT25 - Stora salen 24_25.csv"

courses = SchemaParser.new.parse(file_path)

def week_string(weeks)
  return "(no weeknights)" if weeks.empty?

  "weeks #{weeks.join(", ")}"
end

def weekend_string(weekends)
  return "(no weekend)" if weekends.empty?

  "weekend #{weekends.join(", ")}"
end

courses.each do |course_id, course|
  weeks = course.weeknight_weeks
  weekends = course.weekend_weeks

  puts "#{course_id.ljust(10)} - #{week_string(weeks).ljust(26)} - #{weekend_string(weekends)}"
end

puts "\n---------------------------\n\n"

courses.each do |course_id, course|
  weeks = course.weeknight_dates
  weekends = course.weekend_dates

  puts "#{course_id.ljust(10)} - #{week_string(weeks).ljust(60)} - #{weekend_string(weekends)}"
end
