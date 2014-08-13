#-*- encoding:utf-8 -*-

require 'kconv'
require 'thinreports'

class TrustManagementsController < ApplicationController
  
  before_filter :search_init, :except => ['trust_user_report']
    
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
  
  
  # タックシールを出力する
  def tack_out

    @selected = params[:g1][:selected]
    
    if params[:dm_history] == "1"
      reg_flg = true
    else
      reg_flg = false
    end
    
    owner_id_arr = []
    Trust.where("id in (?)", @selected).each do |trust|
      owner_id_arr.push(trust.owner_id)
    end
    
    # 出力対象が１つもないときはエラー
    if owner_id_arr.length == 0
      flash[:notice] = '印刷対象のチェックボックスをチェックしてください。'
      redirect_to :action => "index" 
    else

      @owners = Owner.where("id in (?)", owner_id_arr)
      #send_data @owners.to_csv, :filename=>'tack.csv'
  
      # pdfファイルを作成
      #report = ThinReports::Report.create :layout => File.join(Rails.root, 'app/reports', 'pdf_layout.tlf') do |r|
      report = ThinReports::Report.create :layout => File.join(Rails.root, 'app/reports', 'pdf_layout.tlf') do |r|
     
         @owners.each_with_index do |owner, idx|
       
           lbl_num = (idx).modulo(8) # 剰余を求める
       
           if lbl_num == 0
             r.start_new_page
           end
       
           r.page.values "post_%02d"%(lbl_num + 1) => owner.postcode
           r.page.values "address_%02d"%(lbl_num + 1) => owner.address 
           r.page.values "name_%02d"%(lbl_num + 1) => owner.name + ' ' + if owner.honorific_title then owner.honorific_title  else '様' end 
           r.page.values "biru_%02d"%(lbl_num + 1) => '(株)中央ビル管理 ' + @biru_user.name
           
           # アプローチデータ登録
           if reg_flg
             owner_approach = OwnerApproach.new
             owner_approach.owner_id = owner.id
             owner_approach.approach_kind_id = ApproachKind.find_by_code('0030').id
             owner_approach.approach_date = params[:dm_out_date]
             owner_approach.content = params[:dm_out_msg]
             owner_approach.biru_user_id = @biru_user.id
             owner_approach.delete_flg = false
             owner_approach.save!
           end
         end
     
       end

       send_data report.generate, :filename    => 'DM_' +  Date.today.to_s +  '.pdf', 
                                  :type        => 'application/pdf', 
                                  :disposition => 'attachment'
    
    end

  end
  
  # 個人別のユーザーレポートを表示します
  def trust_user_report
    
    # ランクがB以上のもの
    # DMを送ったもの
    # 訪問をしたもの
    # TELアプローチしたもの
    
    month = ""
    
    if params[:monthly]
      month = params[:monthly]
    else
      # 当月の月を出す。
      if Date.today.day > 20
        # 翌月
        cur_date = Date.today.next_month
      else
        # 当月
        cur_date = Date.today
      end 
      
      month = "%04d%02d"%[cur_date.year.to_s, cur_date.month.to_s]
    end
    
    @start_date = Date.parse(Date.parse(month + "01").prev_month.strftime("%Y%m")+"21")
    @end_date = Date.parse(month + "20")
    
    
    #####################################
    # 当月にアプローチした貸主を表示    # TODO:リンク時にユーザーを絞り込む
    #####################################
    # 訪問オーナー
    visit_owner = []
    OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0010', '0020')").where("approach_date between ? and ? ", @start_date, @end_date).where("biru_user_id = ?", @biru_user.id).group("owner_approaches.owner_id").select("owner_approaches.owner_id").each do |rec|
      tmp = Owner.find(rec.owner_id)
      visit_owner << tmp if tmp
    end
    gon.visit_owner = visit_owner

    # DMアプローチオーナー
    dm_owner = []
    OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0030')").where("approach_date between ? and ? ", @start_date, @end_date).where("biru_user_id = ?", @biru_user.id).group("owner_approaches.owner_id").select("owner_approaches.owner_id").each do |rec|
      tmp = Owner.find(rec.owner_id)
      dm_owner << tmp if tmp
    end
    gon.dm_owner = dm_owner

    # TELアプローチオーナー
    tel_owner = []
    OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0040')").where("approach_date between ? and ? ", @start_date, @end_date).where("biru_user_id = ?", @biru_user.id).group("owner_approaches.owner_id").select("owner_approaches.owner_id").each do |rec|
      tmp = Owner.find(rec.owner_id)
      tel_owner << tmp if tmp
    end
    gon.tel_owner = tel_owner

    
    #####################################
    # 見込みランクが高い物件を表示    # TODO:リンク時にユーザーを絞り込む
    #####################################
    @buildings = []
    Building.joins(:trusts => :attack_state).where("buildings.code is null").where("trusts.biru_user_id = ?", @biru_user.id).order("attack_states.disp_order").each do |biru|
      
      case biru.trusts[0].attack_state.code
      when 'S'
        biru.tmp_manage_type_icon = "S"
        biru.tmp_build_type_icon = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=S|FFFF00|000000"
        @buildings << biru
      when 'A'
        
        biru.tmp_manage_type_icon = "A"
        biru.tmp_build_type_icon = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=A|00FF00|000000"
        @buildings << biru
        
      when 'B'
        biru.tmp_manage_type_icon = "B"
        biru.tmp_build_type_icon = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=B|00FFFF|000000"
        @buildings << biru
        
      when 'C'
        biru.tmp_manage_type_icon = "C"
        biru.tmp_build_type_icon = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=C|00FF00|000000"
        @buildings << biru
      else
        biru.tmp_manage_type_icon = "不明"
        biru.tmp_build_type_icon = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=F|00FF00|000000"
        @buildings << biru
      end
    end
    
    @shops, @owners, @trusts, @owner_to_buildings, @building_to_owners = get_building_info(@buildings)
    @manage_line_color = make_manage_line_list
    
    # ランクが設定されている物件を表示
    gon.rank_buildings = @buildings
    gon.rank_owners = @owners # 関連する貸主
    gon.rank_trusts = @trusts # 関連する委託契約
    gon.rank_shops = @shops    # 関連する営業所
    gon.rank_owner_to_buildings = @owner_to_buildings # 建物と貸主をひもづける情報
    gon.rank_building_to_owners = @building_to_owners
    gon.rank_manage_line_color = @manage_line_color
    
    gon.all_shops = Shop.find(:all)
    @search_type = 1
    
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
  filter_exist_flg = false

  arr_not_exist = []
  arr_not_exist.push(99999)
  filter_not_exist_flg = false
  
  # 訪問リレキのチェック
  unless @history_visit[:all]
      
    # 訪問リレキで「すべて」以外が選択されているとき
    approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0010', '0020')").where("approach_date between ? and ? ", Date.parse(@history_visit_from), Date.parse(@history_visit_to))
    
    p Date.parse(@history_visit_from)
    p Date.parse(@history_visit_to)
    p approaches.to_sql
    
    if @history_visit[:exist]
      approaches.each do |approach|
        arr_exist.push(approach.owner_id)
      end
      filter_exist_flg = true
      
    elsif @history_visit[:not_exist]
      approaches.each do |approach|
        arr_not_exist.push(approach.owner_id)
      end
      filter_not_exist_flg = true
    end
    
  end
  

  # DMリレキのチェック
  unless @history_dm[:all]
    
    # DMリレキで「すべて」以外が選択されているとき
    approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0030')").where("approach_date between ? and ? ", Date.parse(@history_dm_from), Date.parse(@history_dm_to))
    
    if @history_dm[:exist]
      approaches.each do |approach|
        arr_exist.push(approach.owner_id)
      end
      filter_exist_flg = true
      
    elsif @history_dm[:not_exist]
      approaches.each do |approach|
        arr_not_exist.push(approach.owner_id)
      end
      filter_not_exist_flg = true
      
    end
    
  end
  
  # TELリレキのチェック
  unless @history_tel[:all]
    
    # 訪問リレキで「すべて」以外が選択されているとき
    approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0040')").where("approach_date between ? and ? ", Date.parse(@history_tel_from), Date.parse(@history_tel_to))
    
    if @history_tel[:exist]
      approaches.each do |approach|
        arr_exist.push(approach.owner_id)
      end
      filter_exist_flg = true
      
    elsif @history_tel[:not_exist]
      approaches.each do |approach|
        arr_not_exist.push(approach.owner_id)
      end
      filter_not_exist_flg = true
      
    end
  end
  
  # 絞り込み条件が指定されていた時
  if filter_exist_flg 
      trust_data = trust_data.where("owners.id in (?)", arr_exist) 
  end
  
  if filter_not_exist_flg
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