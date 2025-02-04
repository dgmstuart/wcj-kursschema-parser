#!/usr/bin/env ruby

require "./app/schema_parser"

file_path = "spec/fixtures/Schema kurser HT24-VT25 - Stora salen 24_25.csv"

terms = SchemaParser.new.parse(file_path)

def week_string(weeks)
  return "(no weeknights)" if weeks.empty?

  "weeks #{weeks.join(", ")}"
end

def weekend_string(weekends)
  return "(no weekend)" if weekends.empty?

  "weekend #{weekends.join(", ")}"
end

def print_course_weeks(courses)
  courses.each do |course_id, course|
    weeks = course.weeknight_weeks
    weekends = course.weekend_weeks

    puts "#{course_id.ljust(10)} - #{week_string(weeks).ljust(26)} - #{weekend_string(weekends)}"
  end
end

def print_course_dates(courses)
  courses.each do |course_id, course|
    dates = (course.weeknight_dates + course.weekend_dates).sort

    puts course_id

    if dates.any?
      dates.each { |date| puts date.strftime("%A %-d %B %Y")}
    else
      puts "(no dates)"
    end

    puts "\n"
  end
end

puts terms.autumn.id
puts "---\n"
print_course_weeks(terms.autumn.courses)

puts "\n---------------------------\n\n"

puts terms.autumn.id
puts "---\n"
print_course_dates(terms.autumn.courses)

puts "\n---------------------------\n\n"

puts terms.spring.id
puts "---\n"
print_course_weeks(terms.spring.courses)

puts "\n---------------------------\n\n"

puts terms.spring.id
puts "---\n"
print_course_dates(terms.spring.courses)

