#-*- encoding:utf-8 -*-

require 'kconv'

class TrustManagementsController < ApplicationController
  
  def tack_out
    @selected = params[:g1][:selected]
    @trusts = Trust.joins(:building => :shop ).joins(:owner).joins(:manage_type).where("trusts.id in (?)", @selected)
    
    aaa = []
    @trusts.each do |t|
      aaa.push(t.building.name) if t.building
    end
    
    send_data aaa.to_csv
  end
  
  def index
    # Owner Building Trust を連結した他社データを取得する
    trust_data = get_trust_data
    @trust_arr = initialize_grid(
      trust_data,
      :order => 'shops.code',
      :order_direction => 'desc',
      :per_page => 40,
      :name => 'g1',
      :enable_export_to_csv => false, # データは別ボタンで出力する
      :csv_file_name => 'owner_buildings'      
    )
    
    export_grid_if_requested('g1' => 'owner_building_list', 'g2' => 'projects_grid') do
      # usual render or redirect code executed if the request is not a CSV export request
      render 'owner_building_list'   
    end
    
    if params[:g1] && params[:g1][:selected]
      @selected = params[:g1][:selected]
    end    
        
  end
  
  def owner_show
    get_owner_show(params[:id].to_i)
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
  
  def building_show
    @building = Building.find(params[:id].to_i)
  end
  
  def building_update
    @building = Building.find(params[:id].to_i)
    if @building.update_attributes(params[:building])
      redirect_to :controller=>'trust_managements', :action => 'building_show'
    else
      redirect_to :controller=>'trust_managements', :action => 'building_show'
    end
    
  end
  
  # アプローチ履歴を登録する
  def owner_approach_regist 
    @owner_approach = OwnerApproach.new(params[:owner_approach])
    
    respond_to do |format|
      if @owner_approach.save
        format.html { redirect_to :controller=>'trust_managements', :action => 'owner_show', :id => params[:owner_approach][:owner_id].to_i, notice: 'Book was successfully created.' }
        format.json { render json: @owner_approach, status: :created, location: @owner_approach }
      else
        get_owner_show(params[:owner_approach][:owner_id].to_i)
        format.html { render action: "owner_show" }
        format.json { render json: @owner_approach.errors, status: :unprocessable_entity }
      end
    end    
    
  end
  
  
private
def get_owner_show(owner_id)
  @owner = Owner.find(owner_id)
  
  @trust_arr = initialize_grid(Trust.where("owner_id = ?", @owner.id))
  @owner_approaches = initialize_grid(OwnerApproach.joins(:owner).includes(:biru_user, :approach_kind).where(:owner_id => @owner) )
  
  # 貸主を取得
  gon.owner = @owner 
  
  # 建物を取得
  building_arr = []
  
  Trust.where("owner_id = ?", @owner.id).each do |trust|
    building_arr.push(trust.building)
  end
  
  gon.buildings = building_arr
  
end  

def get_trust_data()
  
  trust_data = Trust.joins(:building => :shop ).joins(:owner).joins(:manage_type).where("owners.code is null")
  
  unless params[:dm]
    #------------------------------------------------#
    # 検索条件が指定されていない時（最初に画面遷移してきた時）
    #------------------------------------------------#
    
    # ログインユーザーが支店長権限があればすべての物件を表示。そうでなければ受託担当者の管理する物件のみを表示する。
    unless @biru_user.attack_all_search 
      trust_data = trust_data.where('buildings.main_employee_id = ?', @biru_user.id)
    end
    
  else
    #-----------------------#
    # 検索条件が指定されている時
    #-----------------------#
    
    # 主担当者が指定
    if params[:main_person]
      unless params[:main_person] == 'all'
        trust_data = trust_data.where('buildings.main_employee_id = ?', params[:main_person] )
      end
    end
    
    # ダイレクトメール発送有無
    if params[:dm] == '1'
      # 対象のみ
      trust_data = trust_data.where('owners.dm_delivery = ?', true)
    elsif  params[:dm] == '2'
      # 対象外のみ
      trust_data = trust_data.where('owners.dm_delivery = ?', false)
    end
    
    # 物件ランク
    if params[:rank] == '1'
      arr = []
      
      arr.push(AttackState.find_by_code('S').id) if params[:rank_kind][:s]
      arr.push(AttackState.find_by_code('A').id) if params[:rank_kind][:a]
      arr.push(AttackState.find_by_code('B').id) if params[:rank_kind][:b]
      arr.push(AttackState.find_by_code('C').id) if params[:rank_kind][:c]
      arr.push(AttackState.find_by_code('D').id) if params[:rank_kind][:d]
      arr.push(AttackState.find_by_code('Z').id) if params[:rank_kind][:z]
      
      trust_data = trust_data.where('buildings.attack_state_id In (?)', arr)
      
    end
    
  end
  
  
  
  trust_data
end
  
end
