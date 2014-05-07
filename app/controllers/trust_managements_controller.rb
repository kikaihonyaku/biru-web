class TrustManagementsController < ApplicationController
  
  def index
    # Owner Building Trust を連結した他社データを取得する
    @trust_arr = initialize_grid(Trust.joins(:building => :shop ).joins(:owner))
    #@trust_arr = initialize_grid(Trust, :joins => [:buidings, :owners] )
  end
  
  def owner_show
    
    @id = params[:id]
    
    @owner = Owner.find(params[:id].to_i)
    @buildings = @owner.buildings
    
  end
  
  
  
end
