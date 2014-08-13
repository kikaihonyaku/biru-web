require 'spec_helper'

describe "biru_user_monthlies/edit" do
  before(:each) do
    @biru_user_monthly = assign(:biru_user_monthly, stub_model(BiruUserMonthly))
  end

  it "renders the edit biru_user_monthly form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", biru_user_monthly_path(@biru_user_monthly), "post" do
    end
  end
end
