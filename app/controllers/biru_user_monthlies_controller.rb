class BiruUserMonthliesController < ApplicationController
  # GET /biru_user_monthlies
  # GET /biru_user_monthlies.json
  def index
    @biru_user_monthlies = BiruUserMonthly.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @biru_user_monthlies }
    end
  end

  # GET /biru_user_monthlies/1
  # GET /biru_user_monthlies/1.json
  def show
    @biru_user_monthly = BiruUserMonthly.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @biru_user_monthly }
    end
  end

  # GET /biru_user_monthlies/new
  # GET /biru_user_monthlies/new.json
  def new
    @biru_user_monthly = BiruUserMonthly.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @biru_user_monthly }
    end
  end

  # GET /biru_user_monthlies/1/edit
  def edit
    @biru_user_monthly = BiruUserMonthly.find(params[:id])
  end

  # POST /biru_user_monthlies
  # POST /biru_user_monthlies.json
  def create
    @biru_user_monthly = BiruUserMonthly.new(params[:biru_user_monthly])

    respond_to do |format|
      if @biru_user_monthly.save
        format.html { redirect_to @biru_user_monthly, notice: 'Biru user monthly was successfully created.' }
        format.json { render json: @biru_user_monthly, status: :created, location: @biru_user_monthly }
      else
        format.html { render action: "new" }
        format.json { render json: @biru_user_monthly.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /biru_user_monthlies/1
  # PUT /biru_user_monthlies/1.json
  def update
    @biru_user_monthly = BiruUserMonthly.find(params[:id])

    respond_to do |format|
      if @biru_user_monthly.update_attributes(params[:biru_user_monthly])
        format.html { redirect_to @biru_user_monthly, notice: 'Biru user monthly was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @biru_user_monthly.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /biru_user_monthlies/1
  # DELETE /biru_user_monthlies/1.json
  def destroy
    @biru_user_monthly = BiruUserMonthly.find(params[:id])
    @biru_user_monthly.destroy

    respond_to do |format|
      format.html { redirect_to biru_user_monthlies_url }
      format.json { head :no_content }
    end
  end
end
