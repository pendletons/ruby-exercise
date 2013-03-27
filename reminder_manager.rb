require 'facets'
require './data_mapper'

class ReminderManager
  # process upcoming reminders for estates, based on their charge schedule and due dates
  # optional output method (to hide extra output when running tests)
  def self.process(output = 'print')
    now = Time.now

    result = ''
    Reminder.all.each do |period|
      # forward X days for reminders
      time = self.adjust_time(now, period.days)

      # format the date to match the database field
      date = time.strftime("#{time.day.ordinalize} %b")

      result += "Estates with due date: #{date}\n"

      # get estates with matching charge periods
      estates = EstateCode.all(:charge_period => period.name, :due_dates.like => "%#{date}%")

      estates.each do |e|
        # find, or if none create, an estate reminder for this charge
        reminder = EstateReminder.first_or_create(:date => now.strftime("%Y-%m-%d"), :code => e.estate_code, :text => "due date #{date} #{time.year}")
        result += "  Reminder set for estate code: #{e.estate_code}\n"
      end
    end

    if output == 'print'
      puts result
    end

    result
  end

  # add day(s) to a time object
  # param Time  time  object to adjust
  # param Int   days  number of days to add
  def self.adjust_time(time, days = 0)
    time + (days * 24 * 60 * 60)
  end
end