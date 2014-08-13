require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe BiruUserMonthliesController do

  # This should return the minimal set of attributes required to create a valid
  # BiruUserMonthly. As you add validations to BiruUserMonthly, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BiruUserMonthliesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all biru_user_monthlies as @biru_user_monthlies" do
      biru_user_monthly = BiruUserMonthly.create! valid_attributes
      get :index, {}, valid_session
      assigns(:biru_user_monthlies).should eq([biru_user_monthly])
    end
  end

  describe "GET show" do
    it "assigns the requested biru_user_monthly as @biru_user_monthly" do
      biru_user_monthly = BiruUserMonthly.create! valid_attributes
      get :show, {:id => biru_user_monthly.to_param}, valid_session
      assigns(:biru_user_monthly).should eq(biru_user_monthly)
    end
  end

  describe "GET new" do
    it "assigns a new biru_user_monthly as @biru_user_monthly" do
      get :new, {}, valid_session
      assigns(:biru_user_monthly).should be_a_new(BiruUserMonthly)
    end
  end

  describe "GET edit" do
    it "assigns the requested biru_user_monthly as @biru_user_monthly" do
      biru_user_monthly = BiruUserMonthly.create! valid_attributes
      get :edit, {:id => biru_user_monthly.to_param}, valid_session
      assigns(:biru_user_monthly).should eq(biru_user_monthly)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new BiruUserMonthly" do
        expect {
          post :create, {:biru_user_monthly => valid_attributes}, valid_session
        }.to change(BiruUserMonthly, :count).by(1)
      end

      it "assigns a newly created biru_user_monthly as @biru_user_monthly" do
        post :create, {:biru_user_monthly => valid_attributes}, valid_session
        assigns(:biru_user_monthly).should be_a(BiruUserMonthly)
        assigns(:biru_user_monthly).should be_persisted
      end

      it "redirects to the created biru_user_monthly" do
        post :create, {:biru_user_monthly => valid_attributes}, valid_session
        response.should redirect_to(BiruUserMonthly.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved biru_user_monthly as @biru_user_monthly" do
        # Trigger the behavior that occurs when invalid params are submitted
        BiruUserMonthly.any_instance.stub(:save).and_return(false)
        post :create, {:biru_user_monthly => {  }}, valid_session
        assigns(:biru_user_monthly).should be_a_new(BiruUserMonthly)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        BiruUserMonthly.any_instance.stub(:save).and_return(false)
        post :create, {:biru_user_monthly => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested biru_user_monthly" do
        biru_user_monthly = BiruUserMonthly.create! valid_attributes
        # Assuming there are no other biru_user_monthlies in the database, this
        # specifies that the BiruUserMonthly created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        BiruUserMonthly.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => biru_user_monthly.to_param, :biru_user_monthly => { "these" => "params" }}, valid_session
      end

      it "assigns the requested biru_user_monthly as @biru_user_monthly" do
        biru_user_monthly = BiruUserMonthly.create! valid_attributes
        put :update, {:id => biru_user_monthly.to_param, :biru_user_monthly => valid_attributes}, valid_session
        assigns(:biru_user_monthly).should eq(biru_user_monthly)
      end

      it "redirects to the biru_user_monthly" do
        biru_user_monthly = BiruUserMonthly.create! valid_attributes
        put :update, {:id => biru_user_monthly.to_param, :biru_user_monthly => valid_attributes}, valid_session
        response.should redirect_to(biru_user_monthly)
      end
    end

    describe "with invalid params" do
      it "assigns the biru_user_monthly as @biru_user_monthly" do
        biru_user_monthly = BiruUserMonthly.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        BiruUserMonthly.any_instance.stub(:save).and_return(false)
        put :update, {:id => biru_user_monthly.to_param, :biru_user_monthly => {  }}, valid_session
        assigns(:biru_user_monthly).should eq(biru_user_monthly)
      end

      it "re-renders the 'edit' template" do
        biru_user_monthly = BiruUserMonthly.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        BiruUserMonthly.any_instance.stub(:save).and_return(false)
        put :update, {:id => biru_user_monthly.to_param, :biru_user_monthly => {  }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested biru_user_monthly" do
      biru_user_monthly = BiruUserMonthly.create! valid_attributes
      expect {
        delete :destroy, {:id => biru_user_monthly.to_param}, valid_session
      }.to change(BiruUserMonthly, :count).by(-1)
    end

    it "redirects to the biru_user_monthlies list" do
      biru_user_monthly = BiruUserMonthly.create! valid_attributes
      delete :destroy, {:id => biru_user_monthly.to_param}, valid_session
      response.should redirect_to(biru_user_monthlies_url)
    end
  end

end
