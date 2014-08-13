require 'spec_helper'

describe "biru_user_monthlies/show" do
  before(:each) do
    @biru_user_monthly = assign(:biru_user_monthly, stub_model(BiruUserMonthly))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
