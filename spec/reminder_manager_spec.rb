require 'spec_helper'

describe ReminderManager do
  describe ".process" do
    before(:each) do
      EstateCode.destroy
      EstateReminder.destroy
    end

    describe "no matching estates" do
      it "should not add any new reminders" do
        quarterly_time = ReminderManager.adjust_time(Time.now, 90)
        quarterly_date = quarterly_time.strftime("#{quarterly_time.day.ordinalize} %b")

        biannual_time = ReminderManager.adjust_time(Time.now, 183)
        biannual_date = biannual_time.strftime("#{biannual_time.day.ordinalize} %b")

        expected = "Estates with due date: #{quarterly_date}\nEstates with due date: #{biannual_date}\n"
        ReminderManager.process(nil).should eq expected
      end
    end

    describe "matching quarterly estates" do
      before(:each) do
        quarterly_time = ReminderManager.adjust_time(Time.now, 90)
        @quarterly_date = quarterly_time.strftime("#{quarterly_time.day.ordinalize} %b")

        @code = EstateCode.create(
          estate_code: 'ABCDE',
          charge_period: 'Quarterly',
          due_dates: @quarterly_date
        )
      end

      it "should add 1 new reminder" do
        biannual_time = ReminderManager.adjust_time(Time.now, 183)
        biannual_date = biannual_time.strftime("#{biannual_time.day.ordinalize} %b")

        expected = "Estates with due date: #{@quarterly_date}\n  Reminder set for estate code: #{@code.estate_code}\nEstates with due date: #{biannual_date}\n"
        ReminderManager.process(nil).should eq expected
        EstateReminder.count.should eq 1
      end
    end

    describe "matching biannual estates" do
      before(:each) do
        biannual_time = ReminderManager.adjust_time(Time.now, 183)
        @biannual_date = biannual_time.strftime("#{biannual_time.day.ordinalize} %b")

        @code = EstateCode.create(
          estate_code: 'ABCDE',
          charge_period: 'Twice a year',
          due_dates: @biannual_date
        )
      end

      it "should add 1 new reminder" do
        quarterly_time = ReminderManager.adjust_time(Time.now, 90)
        quarterly_date = quarterly_time.strftime("#{quarterly_time.day.ordinalize} %b")

        expected = "Estates with due date: #{quarterly_date}\nEstates with due date: #{@biannual_date}\n  Reminder set for estate code: #{@code.estate_code}\n"
        ReminderManager.process(nil).should eq expected
        EstateReminder.count.should eq 1
      end
    end

    describe "matching quarterly and biannual estates" do
      before(:each) do
        quarterly_time = ReminderManager.adjust_time(Time.now, 90)
        @quarterly_date = quarterly_time.strftime("#{quarterly_time.day.ordinalize} %b")

        biannual_time = ReminderManager.adjust_time(Time.now, 183)
        @biannual_date = biannual_time.strftime("#{biannual_time.day.ordinalize} %b")

        @code1 = EstateCode.create(
          estate_code: 'ABCDE',
          charge_period: 'Quarterly',
          due_dates: @quarterly_date
        )
        @code2 = EstateCode.create(
          estate_code: 'ABCDE',
          charge_period: 'Twice a year',
          due_dates: @biannual_date
        )
      end

      it "should add 2 new reminders" do
        expected = "Estates with due date: #{@quarterly_date}\n  Reminder set for estate code: #{@code1.estate_code}\nEstates with due date: #{@biannual_date}\n  Reminder set for estate code: #{@code2.estate_code}\n"
        ReminderManager.process(nil).should eq expected
        EstateReminder.count.should eq 2
      end
    end
  end

  describe ".adjust_time" do
    describe "+30 days" do
      describe "without year wrapping" do
        it "should return the correct date" do
          time = Time.new(2013, 7, 1)
          adjusted = ReminderManager.adjust_time(time, 30)

          adjusted.should eq Time.new(2013, 7, 31)
        end
      end

      describe "with year wrapping" do
        it "should return the correct date from December" do
          time = Time.new(2013, 12, 3)
          adjusted = ReminderManager.adjust_time(time, 30)

          adjusted.should eq(Time.new(2014, 1, 2))
        end
      end
    end

    describe "+60 days" do
      describe "without year wrapping" do
        it "should return the correct date" do
          time = Time.new(2013, 7, 1)
          adjusted = ReminderManager.adjust_time(time, 60)

          adjusted.should eq Time.new(2013, 8, 30)
        end
      end

      describe "with year wrapping" do
        it "should return the correct date from November" do
          time = Time.new(2013, 11, 3)
          adjusted = ReminderManager.adjust_time(time, 60)

          adjusted.should eq(Time.new(2014, 1, 2))
        end

        it "should return the correct date from December" do
          time = Time.new(2013, 12, 1)
          adjusted = ReminderManager.adjust_time(time, 60)

          adjusted.should eq(Time.new(2014, 1, 30))
        end
      end
    end
  end
end