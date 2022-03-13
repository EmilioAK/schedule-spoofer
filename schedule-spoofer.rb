require 'csv'

def make_work_hours(start_time, end_time)
  raise TypeError, 'Start time not a float' unless start_time.is_a? Float
  raise TypeError, 'End time not a float' unless end_time.is_a? Float

  valid_periods = [1, 1.5, 2, 2.5, 3, 3.5]
  work_period = []

  while start_time < end_time
    work_time = valid_periods.sample
    work_time = end_time - start_time if work_time + start_time > end_time
    work_period << { duration: work_time, start_time: start_time }
    start_time += work_time
  end
  work_period
end

def make_task_title(previous)
  titles = ['Coaching call', 'Market research', 'Lead generation', 'Sales calls', 'Writing copy']
  (titles - [previous]).sample
end

def convert_time(time)
  time_a = time.to_s.split('.')
  hour = time_a[0]
  decimal = "0.#{time_a[1]}".to_f
  minutes = (decimal * 60).to_i.to_s.rjust(2, '0')

  "#{hour}:#{minutes}"
end

def make_workday(date, start_time, end_time)
  work_hours = make_work_hours(start_time, end_time)

  work_hours.each_with_object([]) do |work_hour, acc|
    previous_title = acc.dig(-1, 0)
    work_date = "#{date} #{convert_time(work_hour[:start_time])}"
    acc << [make_task_title(previous_title), work_hour[:duration], work_date]
  end
end

def increment_date(date, increment)
  (Date.parse(date) + increment).to_s
end

def make_workdays(start_date, days, start_time, end_time)
  days.times.with_object([]) do |_, workdays|
    workdays << make_workday(start_date, start_time, end_time)
    start_date = increment_date(start_date, 1)
  end.flatten(1)
end

def main
  puts `clear`
  puts 'Input the start-date in this format: 2020-01-01'
  date = gets.chomp
  puts 'Input the start of your work-day in this format: 12'
  start_time = gets.chomp.to_f
  puts 'Input the end of your workday in this format: 17'
  end_time = gets.chomp.to_f
  puts 'Input how many days youd like to create with these hours'
  puts '(work periods will be random but start and end of the work day will be identitical):'
  days = gets.chomp.to_i

  CSV.open('TimeTracker.csv', 'a+') do |csv|
    work_days = make_workdays(date, days, start_time, end_time)
    work_days.each { |period| csv << period }
  end

  puts 'Work-day added to excel file!'
end

main if $PROGRAM_NAME == __FILE__
