#-*- encoding:utf-8 -*-

require 'kconv'

class TrustManagementsController < ApplicationController
  
  before_filter :search_init
    
  def index
        
    if @error_msg.size == 0
      # 検索条件にエラーが存在しないとき
      
      # Owner Building Trust を連結した他社データを取得する
      @trust_data = get_trust_data
      @trust_grid = initialize_grid(
        @trust_data,
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
      
    else
      # 不正な検索条件が指定されたとき
      render 'owner_building_list'   
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
  
  # trustについているdelete_flg の　default_scopeの副作用で、biru_usersのLEFT_OUTER_JOINが効かなくなっている？（空白のものは出てこない・・）なのでそうであればINNER JOINでつないでしまう（2014/07/15）
  #trust_data = Trust.joins(:building => :shop ).joins(:owner).joins(:manage_type).joins("LEFT OUTER JOIN biru_users on trusts.biru_user_id = biru_users.id").where("owners.code is null")
  trust_data = Trust.joins(:building => :shop ).joins(:owner).joins(:manage_type).joins("LEFT OUTER JOIN biru_users on trusts.biru_user_id = biru_users.id").joins("LEFT OUTER JOIN attack_states on trusts.attack_state_id = attack_states.id").where("owners.code is null")
  
  # ログインユーザーが支店長権限があればすべての物件を表示。そうでなければ受託担当者の管理する物件のみを表示する。
  unless @biru_user.attack_all_search 
    trust_data = trust_data.where('trusts.biru_user_id = ?', @biru_user.id)
  end
  
  #----------------------------------#
  # 検索条件が指定されている時の絞り込み
  #----------------------------------#
  
  arr_exist = []
  arr_exist.push(99999)

  arr_not_exist = []
  arr_not_exist.push(99999)
  
  filter_flg = false

  
  # 訪問リレキのチェック
  unless @history_visit[:all]
    
    filter_flg = true
    
    # 訪問リレキで「すべて」以外が選択されているとき
    approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0010', '0020')").where("approach_date between ? and ? ", Date.parse(@history_visit_from), Date.parse(@history_visit_to))
    
    if @history_visit[:exist]
      approaches.each do |approach|
        arr_exist.push(approach.owner_id)
      end
      
    elsif @history_visit[:not_exist]
      approaches.each do |approach|
        arr_not_exist.push(approach.owner_id)
      end
    end
    
  end
  

  # DMリレキのチェック
  unless @history_dm[:all]
    
    filter_flg = true
    
    # 訪問リレキで「すべて」以外が選択されているとき
    approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0030')").where("approach_date between ? and ? ", Date.parse(@history_dm_from), Date.parse(@history_dm_to))
    
    if @history_dm[:exist]
      approaches.each do |approach|
        arr_exist.push(approach.owner_id)
      end
      
    elsif @history_dm[:not_exist]
      approaches.each do |approach|
        arr_not_exist.push(approach.owner_id)
      end
    end
    
  end
  
  # TELリレキのチェック
  unless @history_tel[:all]
    
    filter_flg = true
    
    # 訪問リレキで「すべて」以外が選択されているとき
    approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0040')").where("approach_date between ? and ? ", Date.parse(@history_tel_from), Date.parse(@history_tel_to))
    
    if @history_tel[:exist]
      approaches.each do |approach|
        arr_exist.push(approach.owner_id)
      end
      
    elsif @history_tel[:not_exist]
      approaches.each do |approach|
        arr_not_exist.push(approach.owner_id)
      end
    end
  end
  
  # 絞り込み条件が指定されていた時
  if filter_flg 
      trust_data = trust_data.where("owners.id in (?)", arr_exist) 
      trust_data = trust_data.where("owners.id not in (?)", arr_not_exist) 
  end

  trust_data
end

# 検索条件を初期化します。
def search_init
  
#  if params[:main_person]
#    @main_person = params[:main_person][:name]
#  end
  
  #---------------
  # ダイレクトメール
  #---------------
  # @dm = {}
  # @dm[:all] = false
  # @dm[:only] = false
  # @dm[:not_only] = false
  #
  # if params[:dm]
  #   @dm[params[:dm].to_sym] = true
  # else
  #   @dm[:all] = true
  # end
  #
  # #---------------
  # # 物件ランク
  # #---------------
  # @rank = {}
  # @rank[:all] = false
  # @rank[:only] = false
  #
  # if params[:rank]
  #   @rank[params[:rank].to_sym] = true
  # else
  #   @rank[:all] = true
  # end
  #
  # #---------------
  # # 物件ランク指定
  # #---------------
  # @rank_kind = {}
  #
  # if params[:rank_kind]
  #   if params[:rank_kind][:s] then @rank_kind[:s] = true else @rank_kind[:s] = false end
  #   if params[:rank_kind][:a] then @rank_kind[:a] = true else @rank_kind[:a] = false end
  #   if params[:rank_kind][:b] then @rank_kind[:b] = true else @rank_kind[:b] = false end
  #   if params[:rank_kind][:c] then @rank_kind[:c] = true else @rank_kind[:c] = false end
  #   if params[:rank_kind][:d] then @rank_kind[:d] = true else @rank_kind[:d] = false end
  #   if params[:rank_kind][:z] then @rank_kind[:z] = true else @rank_kind[:z] = false end
  # else
  #   @rank_kind[:s] = false
  #   @rank_kind[:a] = false
  #   @rank_kind[:b] = false
  #   @rank_kind[:c] = false
  #   @rank_kind[:d] = false
  #   @rank_kind[:z] = false
  # end
  
  
  #---------------
  # エラーメッセージ
  #---------------
  @error_msg = []
  
  #---------------
  # 訪問リレキ
  #---------------
  @history_visit = {}
  @history_visit[:all] = false
  @history_visit[:exist] = false
  @history_visit[:not_exist] = false
  
  if params[:history_visit]
    @history_visit[params[:history_visit].to_sym] = true
  else
    @history_visit[:all] = true
  end
  
  @history_visit_from = '1900/01/01'
  @history_visit_to = '3000/01/01'
  
  if params[:history_visit_from]
    @history_visit_from =  params[:history_visit_from]
    
    unless date_check(@history_visit_from)
      @error_msg.push('訪問リレキ(FROM)に不正な日付が入力されました。')
    end
    
  end
  
  if params[:history_visit_to]
    @history_visit_to =  params[:history_visit_to]
    
    unless date_check(@history_visit_to)
      @error_msg.push('訪問リレキ(TO)に不正な日付が入力されました。')
    end
  end

  #---------------------
  # ダイレクトメールリレキ
  #---------------------
  @history_dm = {}
  @history_dm[:all] = false
  @history_dm[:exist] = false
  @history_dm[:not_exist] = false
  
  if params[:history_dm]
    @history_dm[params[:history_dm].to_sym] = true
  else
    @history_dm[:all] = true
  end
  
  @history_dm_from = '1900/01/01'
  @history_dm_to = '3000/01/01'
  
  if params[:history_dm_from]
    @history_dm_from =  params[:history_dm_from] 
    
    unless date_check(@history_dm_from)
      @error_msg.push('ＤＭリレキ(FROM)に不正な日付が入力されました。')
    end
  end
  
  if params[:history_dm_to]
    @history_dm_to =  params[:history_dm_to]
    
    unless date_check(@history_dm_to)
      @error_msg.push('ＤＭリレキ(TO)に不正な日付が入力されました。')
    end
    
  end

  #---------------
  # 電話リレキ
  #---------------
  @history_tel = {}
  @history_tel[:all] = false
  @history_tel[:exist] = false
  @history_tel[:not_exist] = false
  
  if params[:history_tel]
    @history_tel[params[:history_tel].to_sym] = true
  else
    @history_tel[:all] = true
  end
  
  @history_tel_from = '1900/01/01'
  @history_tel_to = '3000/01/01'
  
  if params[:history_tel_from]
    @history_tel_from =  params[:history_tel_from]
    
    unless date_check(@history_tel_from)
      @error_msg.push('ＴＥＬリレキ(FROM)に不正な日付が入力されました。')
    end
    
  end
  
  if params[:history_tel_to]
    @history_tel_to =  params[:history_tel_to]
    
    unless date_check(@history_tel_to)
      @error_msg.push('ＴＥＬリレキ(TO)に不正な日付が入力されました。')
    end
    
  end
  
end

end