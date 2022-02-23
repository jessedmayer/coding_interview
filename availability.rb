require 'json'
require 'date'

#Parse JSON data
file_users = File.read("users.json")
file_events = File.read("events.json")
users_hash = JSON.parse(file_users)
events_hash = JSON.parse(file_events)

#Select the users to Schedule
args = ARGV[0].split(',')
users_to_schedule = []
args.each do |arg|
  users_to_schedule << users_hash.select{|obj| obj["name"] == arg}
end

#Select schedules for given users
current_users_schedules = []
users_to_schedule.each do |user_to_schedule|
  schedule_per_user = events_hash.select{|obj| obj["user_id"] == user_to_schedule.first["id"]}
  schedule_per_user.each do |event|
    current_users_schedules << [DateTime.parse(event["start_time"]), DateTime.parse(event["end_time"])]
  end
end

#Sort user schedules
current_users_schedules = current_users_schedules.sort_by(&:first)

#Merge schedules by start_time
merged_schedules = []
merged_schedules << current_users_schedules[0]
i = 1
j = 0
while i < current_users_schedules.size
  prior_end_time = merged_schedules[j][1]
  current_start_time = current_users_schedules[i][0]
  current_end_time = current_users_schedules[i][1]
  #If prior and current periods overlap
  if prior_end_time >= current_start_time and current_end_time >= prior_end_time
    merged_schedules[j][1] = current_end_time
    #If prior and current periods do not overlap
  elsif prior_end_time < current_start_time
    merged_schedules << current_users_schedules[i]
    j+=1
  end
  i+=1
end

#Calculate availability between user schedules
days = 3
work_day_start = DateTime.parse("2021-07-05T13:00:00")
work_day_end = DateTime.parse("2021-07-05T21:00:00")
final_day = DateTime.parse("2021-07-05T13:00:00").next_day(days)
i = 0
user_availability = []
while work_day_start <=  final_day and i < merged_schedules.size
  current_start_time = merged_schedules[i][0]
  current_end_time = merged_schedules[i][1]
  #Set the prior end time, which would act as availability start time
  if i >= 1
    prior_end_time = merged_schedules[i-1][1]
  else
    prior_end_time = work_day_start
  end
  #Add beginning of day availability if it exists
  if work_day_start < current_start_time
    user_availability << [work_day_start, current_start_time]
    i+=1
    if i >= merged_schedules.size
      break
    end
    prior_end_time = current_end_time
    current_start_time = merged_schedules[i][0]
    current_end_time = merged_schedules[i][1]
  end
  #Increment through current day
  while current_end_time <= work_day_end
    #Only add availability if the prior end time is in the given day
    if prior_end_time > work_day_start
      user_availability << [prior_end_time, current_start_time]
    end
    i+=1
    if i >= merged_schedules.size
      break
    end
    prior_end_time = current_end_time
    current_start_time = merged_schedules[i][0]
    current_end_time = merged_schedules[i][1]
  end

  work_day_start = work_day_start.next_day
  work_day_end = work_day_end.next_day
end

if user_availability.empty?
  puts "No times currently available"
  exit
end

#Print user availability as a time range
current_day = user_availability.first[0].day
user_availability.each do |availability|
  if availability[0].day != current_day
    puts
    current_day = availability[0].day
  end
  puts availability[0].strftime("%Y-%m-%d %H:%M") + " - " + availability[1].strftime("%H:%M")
end

