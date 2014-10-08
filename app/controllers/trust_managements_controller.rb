#-*- encoding:utf-8 -*-

require 'kconv'
require 'thinreports'

class TrustManagementsController < ApplicationController
  
  before_filter :search_init, :except => ['trust_user_report']
    
  def index
    
    user_list = []
    
    # 受託担当者のリスト
    BiruUser.where("code in ('06365','6464','6406','6425','5952','6461','7844','5473','5841','4917','05928')").each do |user|
    	rec = {}
			rec['biru_user_id'] = user.id
			rec['biru_usr_name'] = user.name
			rec['trust_report'] = "trust_user_report?sid=" + user.id.to_s
			rec['attack_list'] = "owner_building_list?sid=" + user.id.to_s
			rec['visit_plan'] = 50
			rec['visit_result'] = 30
			rec['visit_value'] = 20
			rec['dm_plan'] = 500
			rec['dm_result'] = 500
			rec['dm_value'] = 4
			rec['tel_plan'] = 100
			rec['tel_result'] = 100
			rec['tel_value'] = 20
			rec['trust_num'] = 5
			rec['rank_s'] = 3
			rec['rank_a'] = 8
			rec['rank_b'] = 25
			user_list.push(rec)
    end
    gon.data_list = user_list

  end
  
  def owner_building_list
  	
  	# 権限チェック。権限がない人は自分の物件しか見れない
  	unless params[:sid]
  		@error_msg = "パラメータが不正です。"
    else
    	
    	object_user = BiruUser.find(params[:sid].to_i)
    	unless object_user
	  		@error_msg = "指定されたユーザーが存在しません。"
      else
      	if @biru_user.attack_all_search == false && @biru_user.id != object_user.id
		  		@error_msg = "自分以外のアタックリストにアクセスすることはできません。"
      	end
      	
    	end
    	
  	end
    
    # 検索条件にエラーが存在しないとき
    if @error_msg.size == 0
      
	    # 貸主新規作成用
  	  @attack_owner = Owner.new
    
      tmp_building_id = 0
      building_id_arr = []
      trust_manages = []
      
      shops = []
      buildings = []
      trusts = []
      owners = []
      owner_to_buildings = []
      building_to_owners = []
      
      ActiveRecord::Base.connection.select_all(get_trust_sql(object_user)).each do |rec|
        
        #jqgrid用データ
        trust_manages.push(rec)

        # 貸主情報
        owner = {}
        owner[:id] = rec['owner_id']
        owner[:name] = rec['owner_name']
        owner[:address] = rec['owner_address']
        owner[:latitude] = rec['owner_latitude']
        owner[:longitude] = rec['owner_longitude']
        owners.push(owner) unless owners.index(owner)
        
        # 委託情報
        trust = {}
        trust[:owner_id] = rec['owner_id']
        trust[:building_id] = rec['building_id']
        trust[:manage_type_id] = rec[:trust_manage_type_id]
        trusts.push(trust) unless trusts.index(trust)


        # 建物が定義されていた時
        if rec['building_id']

          # 建物情報
          building = {}
          building[:id] = rec['building_id']
          building[:name] = rec['building_name']
          building[:address] = rec['building_address']
          building[:latitude] = rec['building_latitude']
          building[:longitude] = rec['building_longitude']
          buildings.push(building) unless buildings.index(building)
        
          # 営業所情報
          shop = {}
          shop[:id] = rec['shop_id']
          shop[:name] = rec['shop_name']
          shop[:icon] = rec['shop_icon']
          shop[:latitude] = rec['shop_latitude']
          shop[:longitude] = rec['shop_longitude']
          shops.push(shop) unless shops.index(shop)

          # 貸主に紐づく建物一覧を作成する。
          owner_to_buildings[owner[:id]] = [] unless owner_to_buildings[owner[:id]]
          owner_to_buildings[owner[:id]] << building

          # 建物に紐づく貸主一覧を作成する。※本来建物に対するオーナーは１人だが、念のため複数オーナーも対応する。
          building_to_owners[building[:id]] = [] unless building_to_owners[building[:id]]
          building_to_owners[building[:id]] << owner
          
        end
        
          # unless tmp_building_id == rec['building_id']
          #
          #   tmp_building_id = rec['building_id']
          #   building_id_arr.push(rec['building_id'])
          #
          # end
        
      end
      
      # buildings = Building.find_all_by_id(building_id_arr)
      # buildings = [] unless buildings
      #
      # # 絞りこまれた建物を元に、貸主・委託・営業所を取得する
      # buildings_to_gon(buildings)
      
      gon.trust_manages = trust_manages
      gon.buildings = buildings
      gon.owners = owners 
      gon.trusts = trusts
      gon.shops = shops
      gon.owner_to_buildings = owner_to_buildings
      gon.building_to_owners = building_to_owners
      gon.manage_line_color  make_manage_line_list
      gon.all_shops = Shop.find(:all)
      
      render 'owner_building_list'   
      
    else
      # 不正な検索条件が指定されたとき
      render 'owner_building_list'   
    end    
  end
  
  # タックシールを出力する
  def tack_out

    #@selected = params[:g1][:selected]
    @selected = params[:dm_owner_list]
    
    if params[:dm_history] == "1"
      reg_flg = true
    else
      reg_flg = false
    end
    
    owner_id_arr = []
#    Trust.where("id in (?)", @selected).each do |trust|
#      owner = Owner.find(trust.owner_id)
#      owner_id_arr.push(owner.id) if owner.dm_delivery 
#    end
    
    Owner.where("id in (" + @selected + ")" ).each do |owner|
      owner_id_arr.push(owner.id) if owner.dm_delivery 
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
       
           lbl_num = (idx).modulo(21) # 剰余を求める
       
           if lbl_num == 0
             r.start_new_page
           end
       
           unless owner.postcode.blank?
             r.page.values "post_%02d"%(lbl_num + 1) => "〒" + owner.postcode
           end
           
           r.page.values "address_%02d"%(lbl_num + 1) => owner.address 
           r.page.values "name_%02d"%(lbl_num + 1) => owner.name + ' ' + if owner.honorific_title.blank? then '様'  else owner.honorific_title end 
#           r.page.values "biru_%02d"%(lbl_num + 1) => '(株)中央ビル管理 ' + @biru_user.name
           
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
  
  # アタック用の貸主情報登録
  def attack_owner_new
    @attack_owner = Owner.new
  end
  
  # アタック貸主を登録
  def attack_owner_create
    @attack_owner = Owner.new(params[:owner])
    @attack_owner.biru_user_id = @biru_user.id
    
    @attack_owner.attack_code = attack_conv_code(@biru_user.id.to_s,  @attack_owner.address,  @attack_owner.name)
    
    # 住所のGEOCODE
    gmaps_ret = Gmaps4rails.geocode(@attack_owner.address)
    @attack_owner.latitude = gmaps_ret[0][:lat]
    @attack_owner.longitude = gmaps_ret[0][:lng]
    @attack_owner.gmaps = true
    @attack_owner.delete_flg = false
    
    @attack_owner.save!
    
    t = Trust.new
    t.owner_id = @attack_owner.id
    t.biru_user_id = @biru_user.id
    t.save!
    
    redirect_to :action=>'index'
  end
  
  # 個人別のユーザーレポートを表示します
  def trust_user_report
    
    # ランクがB以上のもの
    # DMを送ったもの
    # 訪問をしたもの
    # TELアプローチしたもの
    
    # 対象の期間を取得
    @month = ""
    if params[:month]
      @month = params[:month]
    else
      # 当月の月を出す。
      if Date.today.day > 20
        # 翌月
        cur_date = Date.today.next_month
      else
        # 当月
        cur_date = Date.today
      end 
      
      @month = "%04d%02d"%[cur_date.year.to_s, cur_date.month.to_s]
    end
    
    # 来月度を取得
    tmp_month =Date.parse(@month + "01", "YYYYMMDD").next_month
    @month_next = "%04d%02d"%[tmp_month.year, tmp_month.month]
    
    # 前月度を取得
    tmp_month =Date.parse(@month + "01", "YYYYMMDD").prev_month
    @month_prev = "%04d%02d"%[tmp_month.year, tmp_month.month]
    
    # 今月の集計期間を取得
    @start_date = Date.parse(Date.parse(@month + "01").prev_month.strftime("%Y%m")+"21")
    @end_date = Date.parse(@month + "20")
    
    # ユーザー情報取得
    @biru_trust_user = BiruUser.find(params[:sid])
    
    # この個人レポート画面へのアクセスはログインユーザーと同じか、全員参照権限を持ったユーザーのみ。それ以外はエラーページへリダイレクトする
    unless check_report_auth(@biru_user, @biru_trust_user)
      flash[:notice] = @biru_trust_user.name + 'さんの受託月報ページへアクセスできるのは、ログインユーザー当人か権限をもったユーザーのみです'
      redirect_to :controller=>'pages', :action=>'error_page'
    end
    
    # 当月の計画・実績データを取得
    @biru_user_monthly = BiruUserMonthly.find_by_biru_user_id_and_month(@biru_trust_user.id, @month)
    unless @biru_user_monthly
      @biru_user_monthly = BiruUserMonthly.new
    end
    @biru_user_monthly.biru_user_id = @biru_trust_user.id
    @biru_user_monthly.month = @month
    
    # 来月の計画・実績データを取得
    @biru_user_monthly_next = BiruUserMonthly.find_by_biru_user_id_and_month(@biru_trust_user.id, @month_next)
    unless @biru_user_monthly_next
      @biru_user_monthly_next = BiruUserMonthly.new
    end
    @biru_user_monthly_next.biru_user_id = @biru_trust_user.id
    @biru_user_monthly_next.month = @month_next
    
    
    #####################################
    # 当月に訪問した貸主を表示    
    #####################################
    # 訪問オーナー
    visit_owner_id_arr = []
    @visit_num = 0
    @visit_num_jsk = 0
    
    OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0010', '0020')").where("approach_date between ? and ? ", @start_date, @end_date).where("biru_user_id = ?", @biru_trust_user.id).group("owner_approaches.owner_id, approach_kinds.code").select("owner_approaches.owner_id, approach_kinds.code").each do |rec|
    	
    	visit_owner_id_arr << rec.owner_id
      @visit_num = @visit_num + 1
      
      # 面談できていた時
      if rec.code == '0020'
      	@visit_num_jsk = @visit_num_jsk + 1
      end
      
    end
    gon.visit_owner = Owner.find_all_by_id(visit_owner_id_arr)

		####################################
    # DMアプローチした貸主を表示
		####################################
    dm_owner_id_arr = []
    @dm_num = 0
    @dm_num_jsk = 0

    OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0030', '0035')").where("approach_date between ? and ? ", @start_date, @end_date).where("biru_user_id = ?", @biru_trust_user.id).group("owner_approaches.owner_id, approach_kinds.code").select("owner_approaches.owner_id, approach_kinds.code").each do |rec|
    	dm_owner_id_arr << rec.owner_id
      @dm_num = @dm_num + 1
      
      # ＤＭの「反響」だった時
      if rec.code == '0035'
				@dm_num_jsk = @dm_num_jsk + 1
      end
    end
    
    gon.dm_owner = Owner.find_all_by_id(dm_owner_id_arr)

		####################################
    # ＴＥＬアプローチした貸主を表示
		####################################
    tel_owner_id_arr = []
    @tel_num = 0
    @tel_num_jsk = 0
    
    OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0040', '0045')").where("approach_date between ? and ? ", @start_date, @end_date).where("biru_user_id = ?", @biru_trust_user.id).group("owner_approaches.owner_id, approach_kinds.code").select("owner_approaches.owner_id, approach_kinds.code").each do |rec|
    	tel_owner_id_arr << rec.owner_id
      @tel_num = @tel_num + 1
    	
    	# ＤＭの反響だった時
      if rec.code == '0045'
				@tel_num_jsk = @tel_num_jsk + 1
      end
    end
    gon.tel_owner =  Owner.find_all_by_id(tel_owner_id_arr)
    
    
    #####################################
    # 成約した物件、見込みが高い物件を表示
    #####################################
    @contract_num = 0
    @contract_num_jisya = 0
    
    @buildings = []
    order_hash = TrustAttackStateHistory.joins(:trust).joins(:attack_state_to).where("month <= ?", @month).where("trusts.biru_user_id = ?", @biru_trust_user.id).group("trusts.id").maximum("month")
    
    order_hash.keys.each do |trust_id|
      
      # trust_idにはidが、order_hash[trust_id]にはその月の最大月数が入っている
      
      trust_attack_history = TrustAttackStateHistory.find_by_trust_id_and_month(trust_id, order_hash[trust_id])
      
      # ↓見込みランクの絞り込みはクエリのwhere句の中でなく、集計結果に対して行う。
      # where句でやるとそのランクがある中での最大をとってしまうので、仮にその後に別のランクが登録されていたら本来は必要ないのにそのレコードがとれてしまうから
      case trust_attack_history.attack_state_to.code
      when 'S', 'A', 'B'
        
        biru = trust_attack_history.trust.building
        biru.tmp_manage_type_icon = trust_attack_history.attack_state_to.code
        biru.tmp_build_type_icon = trust_attack_history.attack_state_to.icon
        @buildings << biru
      
      when 'Z'
        # 成約になった物件は、当月のみ表示対象
        if trust_attack_history.month.to_s == @month.to_s

          biru = trust_attack_history.trust.building
          biru.tmp_manage_type_icon = trust_attack_history.attack_state_to.code
          biru.tmp_build_type_icon = trust_attack_history.attack_state_to.icon
          @buildings << biru
          
          # 受託実績戸数を入力
          @contract_num = @contract_num + trust_attack_history.room_num
          
          if trust_attack_history.trust_oneself
            @contract_num_jisya = @contract_num_jisya + trust_attack_history.room_num
          end

          
        end
          
      else
      end
      
    end
    


    #####################################
    # 見込みランクが高い物件を表示   
    #####################################
    # Building.joins(:trusts => :attack_state).where("buildings.code is null").where("trusts.biru_user_id = ?", @biru_trust_user.id).order("attack_states.disp_order").each do |biru|
    #
    #   case biru.trusts[0].attack_state.code
    #   when 'S', 'A', 'B'
    #     biru.tmp_manage_type_icon = biru.trusts[0].attack_state.code
    #     biru.tmp_build_type_icon = biru.trusts[0].attack_state.icon
    #     @buildings << biru
    #   else
    #     # 表示対象の見込みランク以外は表示しない
    #   end
    # end
    
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
    
    # Hashの追加
    station_arr = []
    station_arr.push(["1","15"]) # 草加
    station_arr.push(["1","17"]) # 新田
    station_arr.push(["1","8" ]) # 北千住
    station_arr.push(["1","19"]) # 新越谷
    station_arr.push(["2","14"]) # 南越谷
    station_arr.push(["1","20"]) # 越谷
    station_arr.push(["1","21"]) # 北越谷
    station_arr.push(["1","23"]) # せんげん台
    station_arr.push(["1","26"]) # 春日部
    station_arr.push(["6","6"])  # 戸田公園
    station_arr.push(["7","6"])  # 戸田
    station_arr.push(["11","5"]) # 与野
    station_arr.push(["9","5"])  # 浦和
    station_arr.push(["5","5"])  # 川口
    station_arr.push(["2","12"]) # 東浦和
    station_arr.push(["2","13"]) # 東川口
    station_arr.push(["7","3"])  # 松戸
    station_arr.push(["8","3"])  # 北松戸
    station_arr.push(["2","18"]) # 南流山
    station_arr.push(["3","13"]) # 柏

    # 駅 
#    stations = []
#    stations << Station.find_by_line_code_and_code("1","15") # 草加
#    stations << Station.find_by_line_code_and_code("1","17") # 新田
#    stations << Station.find_by_line_code_and_code("1","8" ) # 北千住
#    stations << Station.find_by_line_code_and_code("1","19") # 新越谷
#    stations << Station.find_by_line_code_and_code("2","14") # 南越谷
#    stations << Station.find_by_line_code_and_code("1","20") # 越谷
#    stations << Station.find_by_line_code_and_code("1","21") # 北越谷
#    stations << Station.find_by_line_code_and_code("1","23") # せんげん台
#    stations << Station.find_by_line_code_and_code("1","26") # 春日部
#    stations << Station.find_by_line_code_and_code("6","6") # 戸田公園
#    stations << Station.find_by_line_code_and_code("7","6") # 戸田
#    stations << Station.find_by_line_code_and_code("11","5") # 与野
#    stations << Station.find_by_line_code_and_code("9","5") # 浦和
#    stations << Station.find_by_line_code_and_code("5","5") # 川口
#    stations << Station.find_by_line_code_and_code("2","12") # 東浦和
#    stations << Station.find_by_line_code_and_code("2","13") # 東川口
#    stations << Station.find_by_line_code_and_code("7","3") # 松戸
#    stations << Station.find_by_line_code_and_code("8","3") # 北松戸
#    stations << Station.find_by_line_code_and_code("2","18") # 南流山
#    stations << Station.find_by_line_code_and_code("3","13") # 柏

		stations = []
		station_arr.each do | station_pair |
			station = Station.find_by_line_code_and_code(station_pair[0], station_pair[1])
			
      # if station
      #   p "駅あり"
      #       else
      #   p "駅なし"
      # end
      #
			stations << station if station
		end

   gon.stations = stations
  end  
  
  def biru_user_trust_update
    
    if params[:biru_user_monthly][:id] == ""
      @biru_user_monthly = BiruUserMonthly.new
    else
      @biru_user_monthly = BiruUserMonthly.find(params[:biru_user_monthly][:id])
    end
    
    @biru_user_monthly.update_attributes(params[:biru_user_monthly])
    
    # 戻る月は前月なので、１ヶ月戻す
    prev_month = Date.parse(@biru_user_monthly.month + '01', "YYYYMMDD").prev_month.strftime("%Y%m")
    redirect_to :action=>'trust_user_report', :sid => @biru_user_monthly.biru_user_id, :month=> prev_month
      
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

#def get_trust_data()
def get_trust_sql(object_user)
  
  # trustについているdelete_flg の　default_scopeの副作用で、biru_usersのLEFT_OUTER_JOINが効かなくなっている？（空白のものは出てこない・・）なのでそうであればINNER JOINでつないでしまう（2014/07/15）
  #trust_data = Trust.joins(:building => :shop ).joins(:owner).joins(:manage_type).joins("LEFT OUTER JOIN biru_users on trusts.biru_user_id = biru_users.id").where("owners.code is null")
  #trust_data = Trust.joins(:building => :shop ).joins(:owner).joins(:manage_type).joins("LEFT OUTER JOIN biru_users on trusts.biru_user_id = biru_users.id").joins("LEFT OUTER JOIN attack_states on trusts.attack_state_id = attack_states.id").where("owners.code is null")
  
  #trust_data = Trust.joins(:owner).joins("LEFT OUTER JOIN manage_types ON trusts.manage_type_id = manage_types.id").joins("LEFT OUTER JOIN buildings on trusts.building_id = buildings.id").joins("LEFT OUTER JOIN shops on buildings.shop_id = shops.id").joins("LEFT OUTER JOIN biru_users on trusts.biru_user_id = biru_users.id").joins("LEFT OUTER JOIN attack_states on trusts.attack_state_id = attack_states.id").where("owners.code is null")
  
  # 指定した列のハッシュだけで返す為に直接SQLを実行する
  sql = ""
  sql = sql + " SELECT trusts.id as trust_id "
  sql = sql + " , trusts.manage_type_id as trust_manage_type_id "
  sql = sql + " , owners.id as owner_id "
  sql = sql + " , owners.attack_code as owner_attack_code "
  sql = sql + " , owners.name as owner_name "
  sql = sql + " , owners.address as owner_address "
  sql = sql + " , owners.memo as owner_memo "
  sql = sql + " , owners.latitude as owner_latitude "
  sql = sql + " , owners.longitude as owner_longitude "
  sql = sql + " , owners.dm_delivery as owner_dm_delivery "
  sql = sql + " , buildings.id as building_id "
  sql = sql + " , buildings.attack_code as building_attack_code "
  sql = sql + " , buildings.name as building_name "
  sql = sql + " , buildings.address as building_address"
  sql = sql + " , buildings.memo as building_memo "
  sql = sql + " , buildings.latitude as building_latitude "
  sql = sql + " , buildings.longitude as building_longitude "
  sql = sql + " , buildings.proprietary_company as building_proprietary_company "
  sql = sql + " , shops.id as shop_id "
  sql = sql + " , shops.name as shop_name "
  sql = sql + " , shops.name as shop_icon "
  sql = sql + " , shops.latitude as shop_latitude "
  sql = sql + " , shops.longitude as shop_longitude "
  sql = sql + " , biru_users.name as biru_user_name "
  sql = sql + " , attack_states.name as attack_states_name "
  sql = sql + " FROM trusts inner join owners on trusts.owner_id = owners.id "
  sql = sql + " inner JOIN manage_types on trusts.manage_type_id = manage_types.id "
  sql = sql + " inner JOIN buildings on trusts.building_id = buildings.id "
  sql = sql + " inner JOIN shops on buildings.shop_id = shops.id "
  sql = sql + " inner JOIN biru_users on trusts.biru_user_id = biru_users.id "
  sql = sql + " left outer JOIN attack_states on trusts.attack_state_id = attack_states.id "
  sql = sql + " WHERE owners.code is null "
  
  
#  # ログインユーザーが支店長権限があればすべての物件を表示。そうでなければ受託担当者の管理する物件のみを表示する。
#  unless @biru_user.attack_all_search 
#    #trust_data = trust_data.where('trusts.biru_user_id = ?', @biru_user.id)
#    sql = sql + " AND trusts.biru_user_id = " + @biru_user.id.to_s
#  end

	sql = sql + " AND trusts.biru_user_id = " + object_user.id.to_s

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
    approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0030','0035')").where("approach_date between ? and ? ", Date.parse(@history_dm_from), Date.parse(@history_dm_to))
    
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
    
    # TELリレキで「すべて」以外が選択されているとき
    approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0040','0045')").where("approach_date between ? and ? ", Date.parse(@history_tel_from), Date.parse(@history_tel_to))
    
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
      # trust_data = trust_data.where("owners.id in (?)", arr_exist) 
      sql = sql + " AND owners.id in (" + arr_exist.join(',') + ") "
  end
  
  if filter_not_exist_flg
    # trust_data = trust_data.where("owners.id not in (?)", arr_not_exist) 
    sql = sql + "AND owners.id not in (" + arr_not_exist.join(',') + ") "
  end

  sql = sql + " ORDER BY buildings.id asc"
  #trust_data
  sql
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

# trust_user_report画面を開くにあたって、アクセス者がログインユーザー当人もしくは権限ユーザーかチェックする
def check_report_auth(login_user, access_user)
  
  return true if login_user.id == access_user.id
  
  return true if login_user.attack_all_search == true
  
  return false
end

end