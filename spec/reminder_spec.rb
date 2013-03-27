require 'spec_helper'

describe Reminder do
  before(:each) do
    EstateReminder.destroy
  end

  describe "#new" do
    before(:each) do
      @name = 'New Period'
      @days = 100
      @reminder = Reminder.new(name: @name, days: @days)
    end

  	it "creates a Reminder object" do
  	  @reminder.should be_an_instance_of Reminder
	  end

    it "sets the name" do
      @reminder.name.should eq @name
    end

    it "sets the days" do
      @reminder.days.should eq @days
    end
  end

  describe ".on" do
    before(:each) do
      @date = Time.now.strftime("%Y-%m-%d")
      @expected = {date: @date, reminders: []}
    end

    describe "without reminders" do
      it "it returns an empty list if no dates match" do
        Reminder.on(@date).should eq @expected
      end
    end

    describe "with reminders" do
      before(:each) do
        @reminder1 = EstateReminder.create(date: @date, code: "ABC", text: "reminder")
        @expected[:reminders] = [@reminder1.to_s]
      end

      describe "single reminder" do
        it "returns a list of reminders that match the date" do
          Reminder.on(@date).should eq @expected
        end
      end

      describe "multiple reminders" do
        before(:each) do
          @reminder2 = EstateReminder.create(date: @date, code: "DEF", text: "reminder")
        end

        it "returns a list of reminders that match the date and code" do
          Reminder.on(@date, ['ABC']).should eq @expected
        end

        it "returns a list of reminders that match the date and multiple codes" do
          @expected[:reminders] = [@reminder1.to_s, @reminder2.to_s]
          Reminder.on(@date, ['ABC', 'DEF']).should eq @expected
        end
      end
    end
  end
end