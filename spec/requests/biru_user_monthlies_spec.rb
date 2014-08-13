require 'spec_helper'

describe "BiruUserMonthlies" do
  describe "GET /biru_user_monthlies" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get biru_user_monthlies_path
      response.status.should be(200)
    end
  end
end
