class BiruUsersController < ApplicationController
  # GET /biru_users
  # GET /biru_users.json
  def index
    @biru_users = BiruUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @biru_users }
    end
  end

  # GET /biru_users/1
  # GET /biru_users/1.json
  def show
    @biru_user = BiruUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @biru_user }
    end
  end

  # GET /biru_users/new
  # GET /biru_users/new.json
  def new
    @biru_user = BiruUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @biru_user }
    end
  end

  # GET /biru_users/1/edit
  def edit
    @biru_user = BiruUser.find(params[:id])
  end

  # POST /biru_users
  # POST /biru_users.json
  def create
    @biru_user = BiruUser.new(params[:biru_user])

    respond_to do |format|
      if @biru_user.save
        format.html { redirect_to @biru_user, notice: 'Biru user was successfully created.' }
        format.json { render json: @biru_user, status: :created, location: @biru_user }
      else
        format.html { render action: "new" }
        format.json { render json: @biru_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /biru_users/1
  # PUT /biru_users/1.json
  def update
    @biru_user = BiruUser.find(params[:id])

    respond_to do |format|
      if @biru_user.update_attributes(params[:biru_user])
        format.html { redirect_to @biru_user, notice: 'Biru user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @biru_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /biru_users/1
  # DELETE /biru_users/1.json
  def destroy
    @biru_user = BiruUser.find(params[:id])
    @biru_user.destroy

    respond_to do |format|
      format.html { redirect_to biru_users_url }
      format.json { head :no_content }
    end
  end
end
