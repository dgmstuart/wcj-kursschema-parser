require "./app/schema_parser"

file_path = "spec/fixtures/Schema kurser HT24-VT25 - Stora salen 24_25.csv"

courses = SchemaParser.new.parse(file_path)

courses.each do |course_id, course|
  weeks = course.weeknight_weeks.join(", ")
  weekends = course.weekend_weeks.join(", ")

  puts "#{course_id} - weeks #{weeks} - weekends #{weekends}"
end
