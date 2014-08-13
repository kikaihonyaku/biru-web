require 'spec_helper'

describe "biru_user_monthlies/index" do
  before(:each) do
    assign(:biru_user_monthlies, [
      stub_model(BiruUserMonthly),
      stub_model(BiruUserMonthly)
    ])
  end

  it "renders a list of biru_user_monthlies" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
