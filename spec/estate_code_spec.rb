require 'spec_helper'

describe EstateCode do
  before(:each) do
    @code = EstateCode.new(estate_code: 'ABCDE', charge_period: 'Quarterly', due_dates: '1st Feb, 3rd May, 1st Aug, 5th Nov')
  end

  describe "#new" do
  	it "creates an Estate Code object" do
  	  @code.should be_an_instance_of EstateCode
	  end

    it "sets the estate code" do
      @code.estate_code.should eq 'ABCDE'
    end

    it "sets the charge period" do
      @code.charge_period.should eq 'Quarterly'
    end

    it "sets the due dates" do
      @code.due_dates.should eq '1st Feb, 3rd May, 1st Aug, 5th Nov'
    end
  end
end