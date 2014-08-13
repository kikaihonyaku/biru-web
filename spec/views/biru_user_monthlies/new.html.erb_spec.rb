require 'spec_helper'

describe "biru_user_monthlies/new" do
  before(:each) do
    assign(:biru_user_monthly, stub_model(BiruUserMonthly).as_new_record)
  end

  it "renders new biru_user_monthly form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", biru_user_monthlies_path, "post" do
    end
  end
end
