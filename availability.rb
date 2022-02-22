require 'json'
require 'date'

class User
  attr_accessor :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  def find_user_availability(events)
    #Find when user is busy
    user_schedule = events.select{|obj| obj.user_id == @id}
  end
end

class Event
  attr_accessor :id, :user_id, :start_time, :end_time

  def initialize(id, user_id, start_time, end_time)
    @id = id
    @user_id = user_id
    @start_time = start_time
    @end_time = end_time
  end
end



dir = 'C:\Users\jdmge\RubymineProjects\Rentgrata Interview Assessment\coding_interview'
file_users = File.read("#{dir}/users.json")
file_events = File.read("#{dir}/events.json")

users_hash = JSON.parse(file_users)
events_hash = JSON.parse(file_events)

users = users_hash.map { |rd| User.new(rd['id'], rd['name']) }
events = events_hash.map { |rd| Event.new(rd['id'], rd['user_id'], rd['start_time'], rd['end_time']) }


#Select the users to Schedule
args = ARGV[0].split(',')
users_to_schedule = []
args.each do |arg|
  users_to_schedule << users.select{|obj| obj.name == arg}
end

#Select schedules for given users
current_users_schedules = []
users_to_schedule.each do |user_to_schedule|
  #p user_to_schedule.first
  #p user_to_schedule.first.find_user_availability(events)

  schedule_per_user = user_to_schedule.first.find_user_availability(events)
  schedule_per_user.each do |event|
    #current_users_schedules << [event.start_time, event.end_time]
    current_users_schedules << [DateTime.parse(event.start_time), DateTime.parse(event.end_time)]
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

#p merged_schedules

#Calculate availability between user schedules
days = 3
work_day_start = DateTime.parse("2021-07-05T13:00:00")
work_day_end = DateTime.parse("2021-07-05T21:00:00")
final_day = DateTime.parse("2021-07-05T13:00:00").next_day(days)
i = 0

#might be an issues where i exceeds the length of merged schedules
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

compressed_user_availability = []
#p user_availability
user_availability.each do |availability|
  #range =
end

#Compress availability start and end times


#p time = DateTime.parse("2021-07-05T13:30:00")
#p now = DateTime.now
#p time < now
# For each find their availability
# Then provide combined availability
