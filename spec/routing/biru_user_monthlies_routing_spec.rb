require "spec_helper"

describe BiruUserMonthliesController do
  describe "routing" do

    it "routes to #index" do
      get("/biru_user_monthlies").should route_to("biru_user_monthlies#index")
    end

    it "routes to #new" do
      get("/biru_user_monthlies/new").should route_to("biru_user_monthlies#new")
    end

    it "routes to #show" do
      get("/biru_user_monthlies/1").should route_to("biru_user_monthlies#show", :id => "1")
    end

    it "routes to #edit" do
      get("/biru_user_monthlies/1/edit").should route_to("biru_user_monthlies#edit", :id => "1")
    end

    it "routes to #create" do
      post("/biru_user_monthlies").should route_to("biru_user_monthlies#create")
    end

    it "routes to #update" do
      put("/biru_user_monthlies/1").should route_to("biru_user_monthlies#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/biru_user_monthlies/1").should route_to("biru_user_monthlies#destroy", :id => "1")
    end

  end
end
