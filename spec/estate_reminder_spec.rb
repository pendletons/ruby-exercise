require 'spec_helper'

describe EstateReminder do
  before(:each) do
    EstateReminder.destroy
  end

  describe "#new" do
    before(:each) do
      @code = '0066S'
      @text = 'due date 1st Feb 2009'
      @reminder = EstateReminder.new(date: '2009-01-01', code: @code, text: @text)
    end

  	it "creates an EstateReminder object" do
  	  @reminder.should be_an_instance_of EstateReminder
	  end

    it "sets the date" do
      @reminder.date.should eq Date.new(2009, 01, 01)
    end

    it "sets the code" do
      @reminder.code.should eq @code
    end

    it "sets the text" do
      @reminder.text.should eq @text
    end
  end

  describe "#to_s" do
    before(:each) do
      @code = '0066S'
      @text = 'due date 1st Feb 2009'
      @reminder = EstateReminder.new(date: '2009-01-01', code: @code, text: @text)
    end

    it "should concatenate code and text" do
      @reminder.to_s.should eq "#{@code} #{@text}"
    end
  end
end