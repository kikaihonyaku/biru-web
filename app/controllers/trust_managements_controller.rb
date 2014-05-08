class TrustManagementsController < ApplicationController
  
  def index
    # Owner Building Trust を連結した他社データを取得する
    @trust_arr = initialize_grid(Trust.joins(:building => :shop ).joins(:owner))
    #@trust_arr = initialize_grid(Trust, :joins => [:buidings, :owners] )
  end
  
  def owner_show
    
    @id = params[:id]
    
    @owner = Owner.find(params[:id].to_i)
    @trust_arr = initialize_grid(Trust.where("owner_id = ?", @owner.id))
  end
  
  def owner_update
    
     @owner = Owner.find(params[:id])
     if @owner.update_attributes(params[:owner])
       
       redirect_to :controller=>'trust_managements', :action => 'owner_show'
       
       #format.html { redirect_to 'index', notice: 'Book was successfully updated.' }
       #format.json { render :show, status: :ok, location: @owner }
     else
       
       redirect_to :controller=>'trust_managements', :action => 'owner_show'
       
       #format.html { render :owner_show }
       #format.json { render json: @book.errors, status: :unprocessable_entity }
     end
   
   
    
  end
  
  
  
  
end
