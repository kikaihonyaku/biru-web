class EmployesController < ApplicationController
  # GET /employes
  # GET /employes.json
  def index
    @employes = Employe.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @employes }
    end
  end

  # GET /employes/1
  # GET /employes/1.json
  def show
    @employe = Employe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @employe }
    end
  end

  # GET /employes/new
  # GET /employes/new.json
  def new
    @employe = Employe.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @employe }
    end
  end

  # GET /employes/1/edit
  def edit
    @employe = Employe.find(params[:id])
  end

  # POST /employes
  # POST /employes.json
  def create
    @employe = Employe.new(params[:employe])

    respond_to do |format|
      if @employe.save
        format.html { redirect_to @employe, notice: 'Employe was successfully created.' }
        format.json { render json: @employe, status: :created, location: @employe }
      else
        format.html { render action: "new" }
        format.json { render json: @employe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /employes/1
  # PUT /employes/1.json
  def update
    @employe = Employe.find(params[:id])

    respond_to do |format|
      if @employe.update_attributes(params[:employe])
        format.html { redirect_to @employe, notice: 'Employe was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @employe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employes/1
  # DELETE /employes/1.json
  def destroy
    @employe = Employe.find(params[:id])
    @employe.destroy

    respond_to do |format|
      format.html { redirect_to employes_url }
      format.json { head :no_content }
    end
  end
end
