require 'dm-core'
require 'dm-migrations'

DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"

# include our models
class EstateCode
  include DataMapper::Resource

  property :id, Serial
  property :estate_code, String
  property :charge_period, String, default: 'Quarterly'
  property :due_dates, String
end

class EstateReminder
  include DataMapper::Resource

  property :id, Serial
  property :date, Date
  property :code, String
  property :text, String

  def to_s
    [code, text].join(' ')
  end

  # return only the text field
  def self.text_only
    all(:fields => [:code, :text])
  end

  # filter reminders by date
  def self.date(date)
    all(:date => date)
  end

  # filter reminders by date and estate code(s)
  #  (query will be (date AND code1) OR (date AND code2), etc.)
  def self.estates(date, codes)
    results = nil
    codes.each do |code|
      current = all(date: date, code: code)
      next unless current
      results = results.nil? ? current : (results | current)
    end

    results
  end
end

class Reminder
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :days, Integer

  # find estate reminders
  # param date     date the reminder should be set (Y-m-d)
  # param estates  list of estate code(s) to filter by (optional)
  # returns list of EstateReminders that match the criteria
  def self.on(date, estates = [])
    result = {date: date, reminders: []}
    if estates.empty?
      # filter by date only
      reminders = EstateReminder.text_only.date(date)
    else
      # filter by date and code(s)
      reminders = EstateReminder.text_only.estates(date, estates)
    end
    # format the reminder ("[code] [text]")
    #  loop with each as map does not play nice with DataMapper Collection
    reminders.each do |r|
      result[:reminders] << r.to_s
    end

    result
  end
end

DataMapper.finalize

DataMapper.auto_migrate!

# seed the dabase
EstateCode.create(
  estate_code: '0066S',
  charge_period: 'Quarterly',
  due_dates: '1st Feb, 3rd May, 1st Aug, 5th Nov'
)
EstateCode.create(
  estate_code: '0123S',
  charge_period: 'Quarterly',
  due_dates: '28th Feb, 31st May, 31st Aug, 30th Nov'
)
EstateCode.create(
  estate_code: '0250S',
  charge_period: 'Twice a year',
  due_dates: '23rd Jan, 22nd Jun'
)
Reminder.create(name: 'Quarterly', days: 90)
Reminder.create(name: 'Twice a year', days: 183)