#-*- encoding:utf-8 -*-

require 'kconv'
require 'thinreports'
require 'csv'

class TrustManagementsController < ApplicationController
  
  before_filter :search_init, :except => ['trust_user_report']
  
  # 受託担当者を規定します
  def get_trust_members
    
    trust_user_hash = {} 
		trust_user_hash['6365'] = {:name=>'松本', :shop_name => '東武南(A)'}
		trust_user_hash['6464'] = {:name=>'猪原', :shop_name => '東武南(B)'}
		trust_user_hash['6425'] = {:name=>'赤坂', :shop_name => '東武北(A)'}
		trust_user_hash['7811'] = {:name=>'赤坂', :shop_name => '東武北(B)'}
		trust_user_hash['5313'] = {:name=>'宮川', :shop_name => 'さいたま中央'}
		trust_user_hash['5518'] = {:name=>'齋藤', :shop_name => 'さいたま東'}
		trust_user_hash['4917'] = {:name=>'市橋', :shop_name => '千葉支店'}
		trust_user_hash['5928'] = {:name=>'テスト', :shop_name => 'テスト'}
    
    return trust_user_hash
    
  end
  
  # アタックリストで貸主を新規作成します
  def popup_owner_create
    
    if params[:owner_name]
      
      # ログインユーザーに紐づく検索可能ユーザーを指定
      @biru_users = get_attack_list_search_users(@biru_user)
      owner_list = Owner.joins(:biru_user).where("biru_user_id in (?)", @biru_users ).select("'<a href=''javascript:win_owner( ' || owners.id || ');'' style=""text-decoration:underline"">' || owners.name || '</a>' as owner_name, owners.kana as owner_kana, owners.address as owner_address,  owners.tel as owner_tel, biru_users.name as biru_user_name")
      
      if params[:owner_name].length > 0
        owner_list = owner_list.where("owners.name like '%" + params[:owner_name] + "%'")
      end

      if params[:owner_kana] && params[:owner_kana].length > 0
        owner_list = owner_list.where("owners.kana like '%" + params[:owner_kana] + "%'")
      end
      
      if params[:owner_address] && params[:owner_address].length > 0
        owner_list = owner_list.where("owners.address like '%" + params[:owner_address] + "%'")
      end
      
      if params[:owner_tel] && params[:owner_tel].length > 0
        owner_list = owner_list.where("owners.tel like '%" + params[:owner_tel] + "%'")
      end
      
      gon.owner_list = owner_list
      @search_owner_name = params[:owner_name]
      @search_owner_kana = params[:owner_kana]
      @search_owner_address = params[:owner_address]
      @search_owner_tel = params[:owner_tel]
      
    end
    
    @header_hidden = true
  end
  
  # アタックリストの貸主に建物を紐付けるための検索画面を表示します。
  def popup_owner_buildings
  
    @owner = Owner.find(params[:owner_id])
  
    if @owner.trusts
      @buildings = []
      
      @owner.trusts.each do |trust|
        @buildings.push(trust.building) if trust.building
      end
      # gon.buildings = buildings
      
    end
  
  
    if params[:building_name]
      # 検索条件が存在した時、検索
    
      # ログインユーザーに紐づく検索可能ユーザーを指定
      @biru_users = get_attack_list_search_users(@biru_user)
    
      building_list = Building.joins(:biru_user).joins(:shop).where("biru_user_id in (?)", @biru_users ).select("'<a href=''javascript:trust_create( #{@owner.id}, ' || buildings.id || ',#{@biru_user.id});'' style=""text-decoration:underline"">' || buildings.name || '</a>' as building_name, buildings.address as building_address, shops.name as shop_name, biru_users.name as biru_user_name")
      
      if params[:building_name].length > 0
        building_list = building_list.where("buildings.name like '%" + params[:building_name] + "%'")
      end

      if params[:building_address] && params[:building_address].length > 0
        building_list = building_list.where("buildings.address like '%" + params[:building_address] + "%'")
      end
            
      gon.building_list = building_list
      @search_building_name = params[:building_name]
      @search_building_address = params[:building_address]
      
    end
  
    @header_hidden = true
  end
  
  
  # biru_userからアタックリストで検索できるユーザーを取得し、biru_usersへ格納します。
  def get_attack_list_search_users(biru_user)

    #--------------------------------
    # 権限によって絞り込める人を定義する
    #--------------------------------
    if biru_user.attack_all_search
      # すべて検索OKの時は受託担当者すべてを表示
      trust_user_hash = get_trust_members
      biru_users = BiruUser.where("code In ( " + trust_user_hash.keys.map{|code| "'" + code.to_s + "'" }.join(',') + ")")
    else
      # すべての権限ではない時、ログインユーザ自身とアクセスが許可されたユーザーを取得
      biru_users = []
      biru_users.push(BiruUser.find(biru_user.id))
      TrustAttackPermission.find_all_by_holder_user_id(biru_user.id).each do |permission|
        biru_users.push(BiruUser.find(permission.permit_user_id))
      end
    end
    
    return biru_users
    
  end
  

  # 受託行動レポート情報を生成します
  def generate_report_info(month, user)
  
    # 来月度を取得
    tmp_month = Date.parse(month + "01", "YYYYMMDD").next_month
    month_next = "%04d%02d"%[tmp_month.year, tmp_month.month]
  
    # 前月度を取得
    tmp_month =Date.parse(month + "01", "YYYYMMDD").prev_month
    month_prev = "%04d%02d"%[tmp_month.year, tmp_month.month]
  
    # 今月の集計期間を取得
    start_date = Date.parse(Date.parse(month + "01").prev_month.strftime("%Y%m")+"21")
    end_date= Date.parse(month + "20")
  
    # 当月の計画・実績データを取得
    biru_user_monthly = BiruUserMonthly.find_by_biru_user_id_and_month(user.id, month)
    unless biru_user_monthly
      biru_user_monthly = BiruUserMonthly.new
    end
    biru_user_monthly.biru_user_id = user.id
    biru_user_monthly.month = month
  
    # 来月の計画・実績データを取得
    biru_user_monthly_next = BiruUserMonthly.find_by_biru_user_id_and_month(user.id, month_next)
    unless biru_user_monthly_next
      biru_user_monthly_next = BiruUserMonthly.new
    end
    biru_user_monthly_next.biru_user_id = user.id
    biru_user_monthly_next.month = month_next

    
    # 登録用のデータ
    report = TrustAttackMonthReport.find_or_create_by_month_and_biru_user_id(month, user.id)
    
    #####################################
    # 当月に訪問した貸主を表示    
    # DMアプローチした貸主を表示
    # ＴＥＬアプローチした貸主を表示
    #####################################
    visit_num_all = 0
    visit_num_meet = 0
    visit_num_suggestion = 0
    
    dm_num_send = 0
    dm_num_recv = 0

    tel_num_call = 0
    tel_num_talk = 0
    
    # 履歴情報の初期化
    TrustAttackMonthReportAction.unscoped.where('trust_attack_month_report_id = ? ', report.id).update_all(:delete_flg=>true)
    OwnerApproach.joins(:approach_kind).where("approach_date between ? and ? ", start_date, end_date).where("biru_user_id = ?", user.id).select("owner_approaches.owner_id, approach_kinds.code, approach_kinds.name, owner_approaches.id as approach_id").each do |rec|
  	
      attack_action = TrustAttackMonthReportAction.unscoped.find_or_create_by_trust_attack_month_report_id_and_owner_approach_id(report.id, rec.approach_id)
      attack_action.trust_attack_month_report_id = report.id
      attack_action.owner_approach_id = rec.approach_id
      
      attack_action.owner_id = rec.owner.id
      attack_action.owner_code = rec.owner.code
      attack_action.owner_name = rec.owner.name
      attack_action.owner_address = rec.owner.address
      attack_action.owner_latitude = rec.owner.latitude
      attack_action.owner_longitude = rec.owner.longitude
      
      
      owner_approach = OwnerApproach.find(rec.approach_id)
      attack_action.content = owner_approach.content
      attack_action.approach_date = owner_approach.approach_date
      attack_action.approach_kind_id = owner_approach.approach_kind_id
      attack_action.approach_kind_code = rec.code
      attack_action.approach_kind_name = rec.name
      
      attack_action.delete_flg = false
      attack_action.save!
      
      case rec.code
      when '0010', '0020', '0025' then
        ########## 訪問・面談・提案 ###########
        if rec.code == '0010'
          # 留守
          visit_num_all = visit_num_all + 1
        elsif rec.code == '0020'
          # 面談
          visit_num_all = visit_num_all + 1
        	visit_num_meet = visit_num_meet + 1
        elsif rec.code == '0025'
          # 提案
          visit_num_all = visit_num_all + 1
        	visit_num_meet = visit_num_meet + 1
          visit_num_suggestion = visit_num_suggestion + 1
        end
      
      when '0030', '0035' then
        ########## DM・DM反響 ###########
        if rec.code == '0030'
          # DM送付
          dm_num_send = dm_num_send + 1
        elsif rec.code == '0035'
          # DM反響
          dm_num_recv = dm_num_recv + 1
        end
              
      when '0040', '0045' then
        ########## TEL・TEL会話 ###########
      	# ＤＭの反響だった時
        if rec.code == '0040'
    			tel_num_call = tel_num_call + 1
        elsif rec.code == '0045'
    			tel_num_call = tel_num_call + 1
    			tel_num_talk = tel_num_talk + 1
        end
        
      else
        # それ以外のとき
      end
    
    end

    #####################################
    # 成約した物件、見込みが高い物件を表示
    #####################################
    trust_num = 0
    trust_num_oneself = 0

    # 件数のカウント
    rank_s = 0
    rank_a = 0
    rank_b = 0
    rank_c = 0
    rank_d = 0
    rank_w = 0
    rank_x = 0
    rank_y = 0
    rank_z = 0
    
    TrustAttackMonthReportRank.unscoped.where('trust_attack_month_report_id = ? ', report.id).update_all(:delete_flg=>true)
    order_hash = TrustAttackStateHistory.joins(:trust).joins(:attack_state_to).where("month <= ?", month).where("trusts.biru_user_id = ?", user.id).group("trusts.id").maximum("month")
    order_hash.keys.each do |trust_id|

      # trust_idにはidが、order_hash[trust_id]にはその月の最大月数が入っている
      trust_attack_history = TrustAttackStateHistory.find_by_trust_id_and_month(trust_id, order_hash[trust_id])

      # ↓見込みランクの絞り込みはクエリのwhere句の中でなく、集計結果に対して行う。
      # where句でやるとそのランクがある中での最大をとってしまうので、仮にその後に別のランクが登録されていたら本来は必要ないのにそのレコードがとれてしまうから
      case trust_attack_history.attack_state_to.code
      when 'S', 'A', 'B', 'C', 'Z'
        # 見込みランクがS・A・B・C・Zのいずれかの時はランク出力対象として保存
        report_rank_regist(report, trust_attack_history, start_date, end_date)
      else
        # 上記のランク以外でも、今月度にランクの変更があったものは出力対象として保存する。
        if trust_attack_history.month.to_s == month.to_s
          report_rank_regist(report, trust_attack_history, start_date, end_date)
        end
      end
      
      case trust_attack_history.attack_state_to.code
      when 'S' then
        rank_s = rank_s + 1
      when 'A' then
        rank_a = rank_a + 1
      when 'B' then
        rank_b = rank_b + 1
      when 'C' then
        rank_c = rank_c + 1
      when 'D' then
        rank_d = rank_d + 1
      when 'W' then
        rank_w = rank_w + 1
      when 'X' then
        rank_x = rank_x + 1
      when 'Y' then
        rank_y = rank_y + 1
      when 'Z' then
        rank_z = rank_z + 1
        
        # 成約になった物件は、当月のみ集計対象
        if trust_attack_history.month.to_s == month.to_s
          
          # B管理以上が集計対象
          if ['3','4','5','6','7','8','9'].include?(trust_attack_history.manage_type.code) 
            
            # 自社・他社の判定
            if trust_attack_history.trust_oneself == true
              trust_num_oneself = trust_num_oneself + trust_attack_history.room_num
            else
              trust_num = trust_num + trust_attack_history.room_num
            end
            
          end
          
        end
        
      else

      end
    end
    
    
    #########################
    # レポートデータの保存
    #########################
    report.month = month
    report.biru_user_id = user.id
    report.biru_usr_name = user.name
    report.trust_report_url = "trust_user_report?sid=" + user.id.to_s
    report.attack_list_url = "owner_building_list?sid=" + user.id.to_s
  
    report.visit_plan = biru_user_monthly.trust_plan_visit
    report.visit_num_all = visit_num_all
    report.visit_num_meet = visit_num_meet
  
    report.dm_plan = biru_user_monthly.trust_plan_dm
    report.dm_num_send = dm_num_send
    report.dm_num_recv = dm_num_recv
  
    report.tel_plan = biru_user_monthly.trust_plan_tel
    report.tel_num_call = tel_num_call
    report.tel_num_talk = tel_num_talk
  
    report.suggestion_plan = biru_user_monthly.trust_plan_suggestion
    report.suggestion_num = visit_num_suggestion
    report.trust_plan = biru_user_monthly.trust_plan_contract
    report.trust_num = trust_num
    report.trust_num_jisya = trust_num_oneself

    report.rank_s = rank_s
    report.rank_a = rank_a
    report.rank_b = rank_b
    report.rank_c = rank_c
    report.rank_d = rank_d
    report.rank_c_over = rank_s + rank_a + rank_b + rank_c
    report.rank_d_over = rank_s + rank_a + rank_b + rank_c + rank_d
  
    report.rank_w = rank_w
    report.rank_x = rank_x
    report.rank_y = rank_y
    report.rank_z = rank_z
  
    # 全件数を取得する
    sql = ""
    sql = sql + "SELECT count(*) as cnt "
    sql = sql + "FROM (" + get_trust_sql(user, "", false) + ") X "
    sql = sql + "where biru_user_id = " + user.id.to_s
    ActiveRecord::Base.connection.select_all(sql).each do |all_cnt_rec|
      report.rank_all = all_cnt_rec['cnt']
    end
    
    ##########################
    # 先月からのランク増減を保存
    ##########################
    report_prev = TrustAttackMonthReport.find_or_initialize_by_month_and_biru_user_id(month_prev, user.id)    
    report.fluctuate_s =  report.rank_s - nz(report_prev.rank_s)
    report.fluctuate_a =  report.rank_a - nz(report_prev.rank_a)
    report.fluctuate_b =  report.rank_b - nz(report_prev.rank_b)
    report.fluctuate_c =  report.rank_c - nz(report_prev.rank_c)
    report.fluctuate_d =  report.rank_d - nz(report_prev.rank_d)
    report.fluctuate_w =  report.rank_w - nz(report_prev.rank_w)
    report.fluctuate_x =  report.rank_x - nz(report_prev.rank_x)
    report.fluctuate_y =  report.rank_y - nz(report_prev.rank_y)
    report.fluctuate_z =  report.rank_z - nz(report_prev.rank_z)
    
    report.save!

  end
  
  # 全件検索
  def search
    
    #----------------
    # 見込みリスト
    #----------------
    rank_arr = []
    
    rank_arr.push('Z') if params[:rank_z]
    rank_arr.push('S') if params[:rank_s]
    rank_arr.push('A') if params[:rank_a]
    rank_arr.push('B') if params[:rank_b]
    rank_arr.push('C') if params[:rank_c]
    rank_arr.push('D') if params[:rank_d]
    
    if params[:rank_wxy] 
       rank_arr.push('W')
       rank_arr.push('X')
       rank_arr.push('Y')
     end
    
    rank_list = ""
    rank_arr.each do |value| 
      if rank_list.length > 0
        rank_list = rank_list + ','
      end
      rank_list = rank_list + "'" + value + "'"
    end
    
    if params[:owner_name]
      
      @search_param = params
      
      if params[:user_id] == ""
        # 指定なしが選択されている時
        @trust_manages = ActiveRecord::Base.connection.select_all(get_trust_sql(@biru_users, rank_list, true, params))
      else
        # 受託担当者が指定されている時
        @trust_manages = ActiveRecord::Base.connection.select_all(get_trust_sql(BiruUser.find(params[:user_id].to_s), rank_list, true, params))
      end

    else
      @trust_manages = []
    end
    
    gon.trust_manages = @trust_manages
    
  end
  
  
  # 貸主情報画面から委託契約（見込みランク）の更新
  def popup_owner_trust_update
    
    pri_trust_attack_update(params[:trust][:id],  params[:month], params[:before_attack_state_id], params[:trust][:attack_state_id], params[:room_num], params[:history][:manage_type], params[:history][:oneself])
    redirect_to :action=>'popup_owner', :controller=>'managements',  :id=>@trust.owner_id
  end
  
  def pri_trust_attack_update(trust_id, month, before_attack_state_id, after_attack_state_id, room_num, manage_type_id, onself_type)
    
    @trust = Trust.find(trust_id)
    
    # 指定された年月のbefore/afterの登録を行う
    history = TrustAttackStateHistory.find_or_create_by_trust_id_and_month(@trust.id, month)
    history.trust_id = @trust.id
    history.month = month
    history.attack_state_from_id = before_attack_state_id
    history.attack_state_to_id = after_attack_state_id
    
    history.room_num = room_num
    history.manage_type_id = manage_type_id
    
    # 自他区分を設定
    if onself_type == 'yourself'
      history.trust_oneself = false
    elsif onself_type  == 'oneself'
      history.trust_oneself = true
    else
      history.trust_oneself = nil
    end
    
    history.save!
    
    # 指定された年月が登録済み履歴の中で最新だった時、委託のランクも更新
    max_month =  TrustAttackStateHistory.where("trust_id = ?", @trust.id ).maximum("month")
    if month == max_month.to_s
      @trust.attack_state_id = after_attack_state_id
      @trust.save!
    end
  end
  

  #def get_trust_data()
  def get_trust_sql(object_user, rank_list, order_flg, search_params=nil)
  
    # trustについているdelete_flg の　default_scopeの副作用で、biru_usersのLEFT_OUTER_JOINが効かなくなっている？（空白のものは出てこない・・）なのでそうであればINNER JOINでつないでしまう（2014/07/15）
    #trust_data = Trust.joins(:building => :shop ).joins(:owner).joins(:manage_type).joins("LEFT OUTER JOIN biru_users on trusts.biru_user_id = biru_users.id").where("owners.code is null")
    #trust_data = Trust.joins(:building => :shop ).joins(:owner).joins(:manage_type).joins("LEFT OUTER JOIN biru_users on trusts.biru_user_id = biru_users.id").joins("LEFT OUTER JOIN attack_states on trusts.attack_state_id = attack_states.id").where("owners.code is null")
  
    #trust_data = Trust.joins(:owner).joins("LEFT OUTER JOIN manage_types ON trusts.manage_type_id = manage_types.id").joins("LEFT OUTER JOIN buildings on trusts.building_id = buildings.id").joins("LEFT OUTER JOIN shops on buildings.shop_id = shops.id").joins("LEFT OUTER JOIN biru_users on trusts.biru_user_id = biru_users.id").joins("LEFT OUTER JOIN attack_states on trusts.attack_state_id = attack_states.id").where("owners.code is null")
  
    # ユーザーが複数指定されているか判定
    if object_user.kind_of?(BiruUser)
      biru_user_id = object_user.id.to_s
      arr_flg = false
    else
    
      biru_user_ids = []
      object_user.each do |biru|
        biru_user_ids.push(biru.id)
      end
       
    
      arr_flg = true
    end
  
    # 指定した列のハッシュだけで返す為に直接SQLを実行する
    sql = ""
    sql = sql + " SELECT trusts.id as trust_id "
    sql = sql + " , trusts.biru_user_id as biru_user_id "
    sql = sql + " , trusts.manage_type_id as trust_manage_type_id "
    sql = sql + " , owners.id as owner_id "
    sql = sql + " , owners.attack_code as owner_attack_code "
    sql = sql + " , owners.name as owner_name "
    sql = sql + " , owners.kana as owner_kana "
    sql = sql + " , owners.address as owner_address "
    sql = sql + " , owners.memo as owner_memo "
    sql = sql + " , owners.latitude as owner_latitude "
    sql = sql + " , owners.longitude as owner_longitude "
    sql = sql + " , owners.dm_delivery as owner_dm_delivery "
    
    sql = sql + " , '<a href=''javascript:win_owner(' || owners.id || ');'' style=""text-decoration:underline"">' || owners.name || '</a>' as owner_name_link" 

    sql = sql + " , owners.dm_ptn_1 as owner_dm_ptn_1 "
    sql = sql + " , owners.dm_ptn_2 as owner_dm_ptn_2 "
    sql = sql + " , owners.dm_ptn_3 as owner_dm_ptn_3 "
    sql = sql + " , owners.dm_ptn_4 as owner_dm_ptn_4 "
    
    sql = sql + " , owners.tel as owner_tel "
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
    sql = sql + " , attack_states.code as attack_states_code "
    sql = sql + " , attack_states.name as attack_states_name "
    # 速度の問題で訪問履歴などの件数は取得しない delete 2015.04.24
    # sql = sql + " , SUM(case approaches.code when '0010' then 1 else 0 end) as visit_rusu "
    # sql = sql + " , SUM(case approaches.code when '0020' then 1 else 0 end) as visit_zai "
    # sql = sql + " , SUM(case approaches.code when '0030' then 1 else 0 end) as dm_send "
    # sql = sql + " , SUM(case approaches.code when '0035' then 1 else 0 end) as dm_res "
    # sql = sql + " , SUM(case approaches.code when '0040' then 1 else 0 end) as tel_call "
    # sql = sql + " , SUM(case approaches.code when '0045' then 1 else 0 end) as tel_speack "
    sql = sql + " FROM trusts inner join owners on trusts.owner_id = owners.id "
    sql = sql + " inner JOIN manage_types on trusts.manage_type_id = manage_types.id "
    sql = sql + " inner JOIN buildings on trusts.building_id = buildings.id "
    sql = sql + " inner JOIN shops on buildings.shop_id = shops.id "
    sql = sql + " inner JOIN biru_users on trusts.biru_user_id = biru_users.id "
    sql = sql + " left outer JOIN attack_states on trusts.attack_state_id = attack_states.id "
    # sql = sql + " left outer JOIN (  "
    # sql = sql + "  select  "
    # sql = sql + "      owner_approaches.owner_id"
    # sql = sql + "     ,owner_approaches.approach_date"
    # sql = sql + "     ,owner_approaches.content"
    # sql = sql + "     ,approach_kinds.code"
    # sql = sql + "     ,approach_kinds.name"
    # sql = sql + "  from owner_approaches inner join approach_kinds on owner_approaches.approach_kind_id = approach_kinds.id"
    # sql = sql + "  where owner_approaches.delete_flg = 'f'"
  
    # # if arr_flg
    # #   sql = sql + "   and owner_approaches.biru_user_id In ( " + biru_user_ids.join(',') + ") "
    # # else
    # #   sql = sql + "   and owner_approaches.biru_user_id = " + biru_user_id + " "
    # # end
    # #
    #sql = sql + "  ) approaches on owners.id = approaches.owner_id"
    sql = sql + " WHERE owners.code is null "
    sql = sql + "   AND trusts.delete_flg = 'f' "
    sql = sql + "   AND owners.delete_flg = 'f' "
    sql = sql + "   AND buildings.delete_flg = 'f' "
  
    # ランク指定がある場合、そのランクのみ表示
    if rank_list.length > 0
      sql = sql + " AND  attack_states.code IN (" + rank_list + ") "
    end
    
  #  # ログインユーザーが支店長権限があればすべての物件を表示。そうでなければ受託担当者の管理する物件のみを表示する。
  #  unless @biru_user.attack_all_search 
  #    #trust_data = trust_data.where('trusts.biru_user_id = ?', @biru_user.id)
  #    sql = sql + " AND trusts.biru_user_id = " + @biru_user.id.to_s
  #  end

    if arr_flg
    	sql = sql + " AND trusts.biru_user_id In ( " + biru_user_ids.join(',') + ") "
    else
    	sql = sql + " AND trusts.biru_user_id = " + biru_user_id + " "
    end
    
    
    #----------------------------------#
    # 検索条件が指定されている時の絞り込み①
    #----------------------------------#
    if search_params
      
      # 貸主名
      if search_params[:owner_name].length > 0
      	sql = sql + " AND owners.name like '%" + search_params[:owner_name].gsub("'","").gsub(";","") + "%' "
      end

      # 物件名
      if search_params[:building_name].length > 0
      	sql = sql + " AND buildings.name like '%" + search_params[:building_name].gsub("'","").gsub(";","") + "%' "
      end


      # 貸主住所
      if search_params[:owner_address].length > 0
      	sql = sql + " AND owners.address like '%" + search_params[:owner_address].gsub("'","").gsub(";","") + "%' "
      end

      # 建物住所
      if search_params[:building_address].length > 0
      	sql = sql + " AND buildings.address like '%" + search_params[:building_address].gsub("'","").gsub(";","") + "%' "
      end


      # 貸主メモ
      if search_params[:owner_memo].length > 0
      	sql = sql + " AND owners.memo like '%" + search_params[:owner_memo].gsub("'","").gsub(";","") + "%' "
      end

      # 建物メモ
      if search_params[:building_memo].length > 0
      	sql = sql + " AND buildings.memo like '%" + search_params[:building_memo].gsub("'","").gsub(";","") + "%' "
      end
      
      if search_params[:shop_id].to_s.length > 0
      	sql = sql + " AND shops.id = " + search_params[:shop_id] + " "
      end
      
    end
    

    #----------------------------------#
    # 検索条件が指定されている時の絞り込み②
    #----------------------------------#
  
    arr_exist = []
    arr_exist.push(99999)
    filter_exist_flg = false

    arr_not_exist = []
    arr_not_exist.push(99999)
    filter_not_exist_flg = false
    
    # 訪問リレキのチェック
    if @history_visit
      
      unless @history_visit[:all]
      
        # 訪問リレキで「すべて」以外が選択されているとき
        # approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0010', '0020')").where("approach_date between ? and ? ", Date.parse(@history_visit_from), Date.parse(@history_visit_to))
    
        # if @history_visit[:exist]
        #   approaches.each do |approach|
        #     arr_exist.push(approach.owner_id)
        #   end
        #   filter_exist_flg = true
        #
        # elsif @history_visit[:not_exist]
        #   approaches.each do |approach|
        #     arr_not_exist.push(approach.owner_id)
        #   end
        #   filter_not_exist_flg = true
        # end
    
        if @history_visit[:exist]
          kinds = ApproachKind.find_all_by_code(['0010', '0020'])
      	  sql = sql + " AND owners.id IN ( select owner_id from owner_approaches where delete_flg = 'f' and approach_kind_id In ( " + kinds.map{ |kind| kind.id }.join(',') +  " ) and approach_date between '" + Date.parse(@history_visit_from).strftime("%Y-%m-%d") + "' and  '" + Date.parse(@history_visit_to).strftime("%Y-%m-%d") + "') "
        end
    
      end
      
    end
  
  

    # DMリレキのチェック
    if @history_dm
      
      unless @history_dm[:all]
    
        # # DMリレキで「すべて」以外が選択されているとき
        # approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0030','0035')").where("approach_date between ? and ? ", Date.parse(@history_dm_from), Date.parse(@history_dm_to))
        #
        # if @history_dm[:exist]
        #   approaches.each do |approach|
        #     arr_exist.push(approach.owner_id)
        #   end
        #   filter_exist_flg = true
        #
        # elsif @history_dm[:not_exist]
        #   approaches.each do |approach|
        #     arr_not_exist.push(approach.owner_id)
        #   end
        #   filter_not_exist_flg = true
        #
        # end

        if @history_dm[:exist]
          kinds = ApproachKind.find_all_by_code(['0030','0035'])
      	  sql = sql + " AND owners.id IN ( select owner_id from owner_approaches where delete_flg = 'f' and approach_kind_id In ( " + kinds.map{ |kind| kind.id }.join(',') +  " ) and approach_date between '" + Date.parse(@history_dm_from).strftime("%Y-%m-%d") + "' and  '" + Date.parse(@history_dm_to).strftime("%Y-%m-%d") + "') "
        end
      end

    
    end
  
    # TELリレキのチェック
    if @history_tel
      unless @history_tel[:all]
    
        # # TELリレキで「すべて」以外が選択されているとき
        # approaches = OwnerApproach.joins(:approach_kind).where("approach_kinds.code IN ('0040','0045')").where("approach_date between ? and ? ", Date.parse(@history_tel_from), Date.parse(@history_tel_to))
        #
        # if @history_tel[:exist]
        #   approaches.each do |approach|
        #     arr_exist.push(approach.owner_id)
        #   end
        #   filter_exist_flg = true
        #
        # elsif @history_tel[:not_exist]
        #   approaches.each do |approach|
        #     arr_not_exist.push(approach.owner_id)
        #   end
        #   filter_not_exist_flg = true
        # end
    
        if @history_tel[:exist]
      
          kinds = ApproachKind.find_all_by_code(['0040','0045'])
      	  sql = sql + " AND owners.id IN ( select owner_id from owner_approaches where delete_flg = 'f' and approach_kind_id In ( " + kinds.map{ |kind| kind.id }.join(',') +  " ) and approach_date between '" + Date.parse(@history_tel_from).strftime("%Y-%m-%d") + "' and  '" + Date.parse(@history_tel_to).strftime("%Y-%m-%d") + "') "
        end
      end
      
    end
    
  
    # # 絞り込み条件が指定されていた時
    # if filter_exist_flg
    #     # trust_data = trust_data.where("owners.id in (?)", arr_exist)
    #     sql = sql + " AND owners.id in (" + arr_exist.join(',') + ") "
    # end
    #
    # if filter_not_exist_flg
    #   # trust_data = trust_data.where("owners.id not in (?)", arr_not_exist)
    #   sql = sql + "AND owners.id not in (" + arr_not_exist.join(',') + ") "
    # end
  
  
    sql = sql + " group by trusts.manage_type_id  "
    sql = sql + " , owners.id  "
    sql = sql + " , trusts.id  "
    sql = sql + " , owners.attack_code  "
    sql = sql + " , owners.name  "
    sql = sql + " , owners.kana  "
    sql = sql + " , owners.address  "
    sql = sql + " , owners.memo  "
    sql = sql + " , owners.latitude  "
    sql = sql + " , owners.longitude  "
    sql = sql + " , owners.dm_delivery  "
    sql = sql + " , owners.tel  "
    sql = sql + " , buildings.id  "
    sql = sql + " , buildings.attack_code  "
    sql = sql + " , buildings.name  "
    sql = sql + " , buildings.address  "
    sql = sql + " , buildings.memo  "
    sql = sql + " , buildings.latitude  "
    sql = sql + " , buildings.longitude  "
    sql = sql + " , buildings.proprietary_company  "
    sql = sql + " , shops.id  "
    sql = sql + " , shops.name  "
    sql = sql + " , shops.name  "
    sql = sql + " , shops.latitude  "
    sql = sql + " , shops.longitude  "
    sql = sql + " , biru_users.name  "
    sql = sql + " , attack_states.name  "  
    sql = sql + " , attack_states.code  "  
    sql = sql + " , trusts.biru_user_id  "  

  	# 複数指定
  	if order_flg
      #sql = sql + " ORDER BY buildings.id asc"
      sql = sql + " ORDER BY owners.id asc"
    end

    sql
  end

  
  
  def index
    
    @month = ""
    if params[:month]
      @month = params[:month]
    else
      @month = get_cur_month
    end
    
    dt_base = Date.parse(@month + '01', "YYYYMMDD").months_ago(5)
    
		@calender = []
    10.times{
      @calender.push([dt_base.strftime("%Y/%m"), dt_base.strftime("%Y%m") ])
      dt_base = dt_base.next_month
    }

    user_list = []
    
    # 受託担当者のリスト
    trust_user_hash = get_trust_members

    # ユーザーを取得
    biru_users = BiruUser.where("code In ( " + trust_user_hash.keys.map{|code| "'" + code.to_s + "'" }.join(',') + ")")
    # 全件件数を取得するためのSQL
    all_cnt_hash = {}
    sql = ""
    sql = sql + "SELECT biru_user_id, count(*) as cnt "
    sql = sql + "FROM (" + get_trust_sql(biru_users, "", false) + ") X "
    sql = sql + "GROUP BY biru_user_id "
    ActiveRecord::Base.connection.select_all(sql).each do |all_cnt_rec|
      all_cnt_hash[BiruUser.find(all_cnt_rec['biru_user_id']).code] = all_cnt_rec['cnt']
    end
    
		trust_user_hash.keys.each do |key|
		  
			rec = {}
			
			# レポート表示用データ取得
			exist_flg = false
		  trust_user = BiruUser.find_by_code(key)
		  if trust_user
		  	# ワークデータで作成済みのデータを取得する
		  	report = TrustAttackMonthReport.find_by_month_and_biru_user_id(@month, trust_user.id)
		  	if report
		  		exist_flg = true
			  end
			end
		  
		  if exist_flg
		  	
				rec['biru_user_id'] = report.biru_user_id.to_s
				rec['biru_usr_name'] = report.biru_usr_name
				rec['shop_name'] = trust_user_hash[key][:shop_name]
				
				rec['trust_report'] = report.trust_report_url
				rec['attack_list'] = report.attack_list_url
        
				rec['visit_plan'] = report.visit_plan
				rec['visit_num_all'] = report.visit_num_all
				rec['visit_num_meet'] = report.visit_num_meet
				rec['dm_plan'] = report.dm_plan
				rec['dm_num_send'] = report.dm_num_send
				rec['dm_num_recv'] = report.dm_num_recv
				rec['tel_plan'] = report.tel_plan
				rec['tel_num_call'] = report.tel_num_call
				rec['tel_num_talk'] = report.tel_num_talk
        rec['trust_plan'] = report.trust_plan
				rec['trust_num'] = report.trust_num
		    rec['suggestion_plan'] = report.suggestion_plan
		    rec['suggestion_num'] = report.suggestion_num
        
				rec['rank_s'] = report.rank_s
				rec['rank_a'] = report.rank_a
				rec['rank_b'] = report.rank_b
				rec['rank_c'] = report.rank_c
				rec['rank_d'] = report.rank_d
		    rec['rank_all'] = report.rank_all
        
				rec['rank_c_over'] = nz(report.rank_s) + nz(report.rank_a) + nz(report.rank_b) + nz(report.rank_c) 
				rec['rank_d_over'] = nz(report.rank_s) + nz(report.rank_a) + nz(report.rank_b) + nz(report.rank_c) + nz(report.rank_d)
		    rec['rank_etc'] = nz(report.rank_w) + nz(report.rank_x) + nz(report.rank_y) + nz(report.rank_z)
        
		  else
		    
				rec['biru_user_id'] = 1.to_s
				rec['biru_usr_name'] = 'xxx'
				rec['trust_report'] = "trust_user_report?sid=" + 1.to_s
				rec['attack_list'] = "owner_building_list?sid=" + 1.to_s
		    # rec['visit_plan'] = 0
		    # rec['visit_result'] = 0
		    # rec['visit_value'] = 0
		    # rec['dm_plan'] = 0
		    # rec['dm_result'] = 0
		    # rec['dm_value'] = 0
		    # rec['tel_plan'] = 0
		    # rec['tel_result'] = 0
		    # rec['tel_value'] = 0
		    # rec['trust_num'] = 0
		    # rec['rank_s'] = 0
		    # rec['rank_a'] = 0
		    # rec['rank_b'] = 0
		    
		  end

			user_list.push(rec)
		  
		end

    @data_update = TrustAttackMonthReportUpdateHistory.find_by_month(@month)
    gon.data_list = user_list

  end
  
  
  def owner_building_list
  	
  	# 権限チェック。権限がない人は自分の物件しか見れない
    # unless params[:sid]
    #   @error_msg = "パラメータが不正です。"
    #     else
    #       @object_user = BiruUser.find(params[:sid].to_i)
    #       unless @object_user
    #         @error_msg = "指定されたユーザーが存在しません。"
    #       else
    #         unless check_report_auth(@biru_user, @object_user)
    #       @error_msg = "自分以外のアタックリストにアクセスすることはできません。"
    #         end
    #       end
    # end
    
    # 2015/08/27 update ログインユーザーが該当する物件にアクセスできるようにする。
    @object_user = @biru_user
    
    # 見込みランクの指定
    rank_list = ""
    @disp_search = false
    
    unless params[:owner_name]
      
      
      ###############################################
      # 再検索させるように、初期表示のヒットは０件にする。
      ###############################################
      rank_list = '999'
      @disp_search = true
      param_tmp = nil
    else
      
      param_tmp = params
      @search_param = params
      
      # アタックリスト一覧から再検索してきた時
      rank_arr = []
      rank_arr.push('S') if params[:rank_s]
      rank_arr.push('A') if params[:rank_a]
      rank_arr.push('B') if params[:rank_b]
      rank_arr.push('C') if params[:rank_c]
      rank_arr.push('D') if params[:rank_d]
      rank_arr.push('W') if params[:rank_w]
      rank_arr.push('X') if params[:rank_x]
      rank_arr.push('Y') if params[:rank_y]
      rank_arr.push('Z') if params[:rank_z]
      
      rank_arr.each do |value|
        
        if rank_list.length > 0
          rank_list = rank_list + ','
        end
        
        rank_list = rank_list + "'" + value + "'"
      end
      
    end
    
    @combo_shop = jqgrid_combo_shop
    
    
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
      owner_to_buildings = {}
      building_to_owners = {}
      
      
      
      if params[:user_id] == nil or params[:user_id] == ""
        # 指定なしが選択されている時
        search_user = @biru_users
      else
        # 受託担当者が指定されている時
        search_user = BiruUser.find(params[:user_id].to_s)
      end
      
      ActiveRecord::Base.connection.select_all(get_trust_sql(search_user, rank_list, true, param_tmp)).each do |rec|
        
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
        trust[:attack_states_code] = rec['attack_states_code']
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
      
      
      # ランク見込みオプション
      @rank_searchoptions = ""
      AttackState.all.each do |rank|
        @rank_searchoptions = @rank_searchoptions + ";" + rank.code + ":" + rank.name 
      end
      
      render 'owner_building_list'   
      
    else
      # 不正な検索条件が指定されたとき
      render 'owner_building_list'   
    end    
  end
  
  # タックシールを出力する
  def tack_out

    @selected = params[:dm_owner_list]
    
    if params[:dm_history] == "1"
      reg_flg = true
    else
      reg_flg = false
    end
    
    # owner_id_arr = []
    #
    # Owner.where("id in (" + @selected + ")" ).each do |owner|
    #   owner_id_arr.push(owner.id) if owner.dm_delivery
    # end
    #
    # # 出力対象が１つもないときはエラー
    # if owner_id_arr.length == 0
    #   flash[:notice] = '印刷対象のチェックボックスをチェックしてください。'
    #   redirect_to :action => "index"
    
    
    msg = ""
    rank_arr = []
    ptn_str = ""
    
    ####################
    # ランクのチェック
    ####################
    rank_arr.push('S') if params[:rank_s]
    rank_arr.push('A') if params[:rank_a]
    rank_arr.push('B') if params[:rank_b]
    rank_arr.push('C') if params[:rank_c]
    rank_arr.push('D') if params[:rank_d]

    if rank_arr.length == 0
      msg = msg + '出力対象の見込みランクが未指定です。　　　'
    end
    
    ####################
    # パターンのチェック
    ####################
    if params[:ptn_1]
      ptn_str = ptn_str + " dm_ptn_1 = 't'" # SQLServerは1
    end

    if params[:ptn_2]
      unless ptn_str == ""
        ptn_str = ptn_str + " Or "
      end
      
      ptn_str = ptn_str + " dm_ptn_2 = 't'" # SQLServerは2
    end

    if params[:ptn_3]
      unless ptn_str == ""
        ptn_str = ptn_str + " Or "
      end
      
      ptn_str = ptn_str + " dm_ptn_3 = 't'" # SQLServerは2
    end

    if params[:ptn_4]
      unless ptn_str == ""
        ptn_str = ptn_str + " Or "
      end
      
      ptn_str = ptn_str + " dm_ptn_4 = 't'" # SQLServerは2
    end
    
    if ptn_str == ""
      msg = msg + '出力対象のパターンが未指定です。　　　'
    end
    
    # パラメータが不正の時はエラーメッセージを表示
    unless msg == ""
        flash[:notice] = msg
        p msg
        redirect_to :action => "index"
    else
      
      rank_tmp = ""
      rank_arr.each do |rank|
        unless rank_tmp == ""
          rank_tmp = rank_tmp + ","
        end
        
        rank_tmp = rank_tmp + "'" + rank + "'"
      end
      
      str_sql = ""
      str_sql = str_sql + " SELECT distinct owners.id as owner_id"
      str_sql = str_sql + " FROM owners inner join trusts on owners.id = trusts.owner_id "
      str_sql = str_sql + " inner join attack_states on trusts.attack_state_id = attack_states.id "
      str_sql = str_sql + " where trusts.biru_user_id = " + params[:sid]
      str_sql = str_sql + " and trusts.delete_flg = 'f'"
      str_sql = str_sql + " and owners.delete_flg = 'f'"
      str_sql = str_sql + " and owners.dm_delivery = 't' "
      str_sql = str_sql + " and attack_states.code in ( " + rank_tmp + ")  "
      str_sql = str_sql + " and  ( " + ptn_str + ")  "
      
      owner_id_arr = []
      ActiveRecord::Base.connection.select_all(str_sql).each do |rec|
        owner_id_arr.push(rec['owner_id'])
      end
      
      @owners = Owner.find_all_by_id(owner_id_arr)
  
      # pdfファイルを作成
      #report = ThinReports::Report.create :layout => File.join(Rails.root, 'app/reports', 'pdf_layout.tlf') do |r|
      report = ThinReports::Report.create :layout => File.join(Rails.root, 'app/reports', params[:dm_tack_kind]) do |r|
     
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
  
  # ファイル出力（CSV出力）
  def csv_out
    str = ""
    
    params[:data].keys.each do |key|
      str = str + params[:data][key].values.join(',')
      str = str + "\n"
    end
    
    send_data str, :filename=>'output.csv'
  end
  
  
  # # アタック用の貸主情報登録
  # def attack_owner_new
  #   @attack_owner = Owner.new
  # end
  #
  # # アタック貸主を登録
  # def attack_owner_create
  #   @attack_owner = Owner.new(params[:owner])
  #   @attack_owner.biru_user_id = @biru_user.id
  #
  #   @attack_owner.attack_code = attack_conv_code(@biru_user.id.to_s,  @attack_owner.address,  @attack_owner.name)
  #
  #   # 住所のGEOCODE
  #   gmaps_ret = Gmaps4rails.geocode(@attack_owner.address)
  #   @attack_owner.latitude = gmaps_ret[0][:lat]
  #   @attack_owner.longitude = gmaps_ret[0][:lng]
  #   @attack_owner.gmaps = true
  #   @attack_owner.delete_flg = false
  #
  #   @attack_owner.save!
  #
  #   t = Trust.new
  #   t.owner_id = @attack_owner.id
  #   t.biru_user_id = @biru_user.id
  #   t.save!
  #
  #   redirect_to :action=>'index'
  # end

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
      @month = get_cur_month
    end
    
    # 来月度を取得
    tmp_month = Date.parse(@month + "01", "YYYYMMDD").next_month
    @month_next = "%04d%02d"%[tmp_month.year, tmp_month.month]
  
    # 前月度を取得
    tmp_month =Date.parse(@month + "01", "YYYYMMDD").prev_month
    @month_prev = "%04d%02d"%[tmp_month.year, tmp_month.month]
    
    # ユーザー情報取得
    @biru_trust_user = BiruUser.find(params[:sid])
    
    # この個人レポート画面へのアクセスはログインユーザーと同じか、全員参照権限を持ったユーザーのみ。それ以外はエラーページへリダイレクトする
    unless check_report_auth(@biru_user, @biru_trust_user)
      flash[:notice] = @biru_trust_user.name + 'さんの受託月報ページへアクセスできるのは、ログインユーザー当人か権限をもったユーザーのみです'
      redirect_to :controller=>'pages', :action=>'error_page'
    end
    
    # レポート情報の取得
    @report = TrustAttackMonthReport.find_or_create_by_month_and_biru_user_id(@month, @biru_trust_user.id)
    
    # 来月の計画・実績データを取得
    @biru_user_monthly_next = BiruUserMonthly.find_by_biru_user_id_and_month(@biru_trust_user.id, @month_next)
    unless @biru_user_monthly_next
      @biru_user_monthly_next = BiruUserMonthly.new
    end
    @biru_user_monthly_next.biru_user_id = @biru_trust_user.id
    @biru_user_monthly_next.month = @month_next

    #     @visit_owner_id_arr = @report.visit_owners_absence
    #     @dm_owner_id_arr = @report.dm_owners_send
    #     @tel_owner_id_arr = @report.tel_owners_call
    #     #@buildings = result[:buildings]
    #
    #     @buildings = []
    #     Trust.where("id in (" + @report.rank_b_trusts + ")").each do |trust|
    #       @buildings << trust.building
    #     end
    #
    #     # 物件情報の取得
    #     gon.visit_owner = Owner.find_all_by_id(@visit_owner_id_arr)
    #     gon.dm_owner = Owner.find_all_by_id(@dm_owner_id_arr)
    #     gon.tel_owner =  Owner.find_all_by_id(@tel_owner_id_arr)
    #
    #     @shops, @owners, @trusts, @owner_to_buildings, @building_to_owners = get_building_info(@buildings)
    #     @manage_line_color = make_manage_line_list
    #
    #     # ランクが設定されている物件を表示
    #     gon.rank_buildings = @buildings
    #     gon.rank_owners = @owners # 関連する貸主
    #     gon.rank_trusts = @trusts # 関連する委託契約
    #     gon.rank_shops = @shops    # 関連する営業所
    #     gon.rank_owner_to_buildings = @owner_to_buildings # 建物と貸主をひもづける情報
    #     gon.rank_building_to_owners = @building_to_owners
    #     gon.rank_manage_line_color = @manage_line_color
    #
    #     gon.all_shops = Shop.find(:all)
    #     @search_type = 1
    #
    #     # 駅の追加
    #     station_arr = []
    #     station_arr.push(["1","15"]) # 草加
    #     station_arr.push(["1","17"]) # 新田
    #     station_arr.push(["1","8" ]) # 北千住
    #     station_arr.push(["1","19"]) # 新越谷
    #     station_arr.push(["2","14"]) # 南越谷
    #     station_arr.push(["1","20"]) # 越谷
    #     station_arr.push(["1","21"]) # 北越谷
    #     station_arr.push(["1","23"]) # せんげん台
    #     station_arr.push(["1","26"]) # 春日部
    #     station_arr.push(["6","6"])  # 戸田公園
    #     station_arr.push(["7","6"])  # 戸田
    #     station_arr.push(["11","5"]) # 与野
    #     station_arr.push(["9","5"])  # 浦和
    #     station_arr.push(["5","5"])  # 川口
    #     station_arr.push(["2","12"]) # 東浦和
    #     station_arr.push(["2","13"]) # 東川口
    #     station_arr.push(["7","3"])  # 松戸
    #     station_arr.push(["8","3"])  # 北松戸
    #     station_arr.push(["2","18"]) # 南流山
    #     station_arr.push(["3","13"]) # 柏
    #
    # stations = []
    # station_arr.each do | station_pair |
    #   station = Station.find_by_line_code_and_code(station_pair[0], station_pair[1])
    #
    #       # if station
    #       #   p "駅あり"
    #       #       else
    #       #   p "駅なし"
    #       # end
    #       #
    #   stations << station if station
    # end
    #
    #    gon.stations = stations
   
   ######################
   # 行動内訳履歴を表示
   ######################
   grid_data_approach = []
   approach_owners = []
   check_owner = {}
   
   @report.trust_attack_month_report_actions.each do |action_rec|
   
     no_dm = true # 2015.07.22 DMだったら地図に出さないようにする。
     
     case action_rec.approach_kind_code
     when '0010', '0020' # 訪問
       icon = '/assets/marker_btn_blue.png'
     when '0030', '0035' # ＤＭ
       icon = '/assets/marker_btn_green.png'
       no_dm = false
     when '0040', '0045' # 電話
       icon = '/assets/marker_btn_orange.png'
     when '0025' # 提案
       icon = '/assets/marker_btn_red.png'
     else
       icon = '/assets/marker_gray.png'
     end
   
     # 地図へ表示するアイコンの情報
     approach_owner = {
         :id=>action_rec.owner_id, :name=>action_rec.owner_name, :latitude=>action_rec.owner_latitude, :longitude=>action_rec.owner_longitude, :icon=>icon
     }
   
     # 2015.07.22 DM以外を地図のアイコン表示
     if no_dm
       unless check_owner[approach_owner[:id]]
         approach_owners.push(approach_owner)
         check_owner[approach_owner[:id]] = true
       end     
     end
   
     # アプローチ種別が面談・電話会話・DM反響・提案の時のみ行動詳細に表示
     case action_rec.approach_kind_code
     when '0020', '0035', '0045', '0025'
       # jqgridに表示する一覧の情報(訪問の面談・提案・TELの応答のみ表示。それ以外は対象外)
       row_data = {}
       row_data[:owner_id] = action_rec.owner_id
       row_data[:approach_kind] = action_rec.approach_kind_name
       row_data[:approach_date] = action_rec.approach_date
       row_data[:approach_content] = action_rec.content
       row_data[:owner_code] = action_rec.owner_code
       row_data[:owner_name] = action_rec.owner_name
       row_data[:owner_address] = action_rec.owner_address

       grid_data_approach.push(row_data)
     end
   end
   
   gon.grid_data_approach = grid_data_approach
   gon.approach_owners = approach_owners
   
   # 一覧をしぼったコンボボックスの表示
   result = ":"
   ApproachKind.where("code in ('0020', '0035', '0045', '0025')").order(:sequence).each do |obj|
     result = result + ";" + obj.name + ":" + obj.name
   end
   result
      
   @combo_approach_kinds = result
   
   
   
   ######################
   # ランクデータを表示
   ######################
   grid_data_rank = []
   rank_buildings = []
   check_building = {}
   
   @report.trust_attack_month_report_ranks.each do |rank_rec|
     
     unless rank_rec.attack_state_this_month
     	 p 'trust_attack_month_report_ranks: ' + rank_rec.id.to_s
     	 next 
     end
     
     
     case rank_rec.attack_state_this_month.code
     when 'S'
       icon = '/assets/marker_orange.png'
     when 'A'
       icon = '/assets/marker_green.png'
     when 'B'
       icon = '/assets/marker_purple.png'
     when 'C'
       icon = '/assets/marker_red.png'
     when 'Z'
       icon = '/assets/marker_white.png'
     else
       icon = '/assets/marker_gray.png'
     end
   
     # 地図へ表示するアイコンの情報
     rank_building = {
         :id=>rank_rec.building_id, :name=>rank_rec.building_name, :latitude=>rank_rec.building_latitude, :longitude=>rank_rec.building_longitude, :icon=>icon, :owner_id=>rank_rec.owner_id
     }
   
     unless check_building[rank_building[:id]]
       rank_buildings.push(rank_building)
       check_building[rank_building[:id]] = true
     end     
     
     
     row_data = {}
     row_data[:attack_state_last_month] = rank_rec.attack_state_last_month.code
     row_data[:attack_state_this_month] = rank_rec.attack_state_this_month.code
     
     case rank_rec.change_status
     when 0
       row_data[:change_status] = "変更なし"
     when 1
       row_data[:change_status] = "ランクダウン"
     when 2
       row_data[:change_status] = "ランクアップ"
     else
       row_data[:change_status] = "不明"
     end
       
     row_data[:change_month] = rank_rec.change_month
     row_data[:building_id] = rank_rec.building_id
     row_data[:building_name] = rank_rec.building_name
     row_data[:owner_id] = rank_rec.owner_id
     
     row_data[:approach_cnt] = rank_rec.approach_cnt
     
     grid_data_rank.push(row_data)
   end
   gon.grid_data_rank = grid_data_rank
   gon.rank_buildings = rank_buildings
   
   
   @combo_rank = jqgrid_combo_rank
   @data_update = TrustAttackMonthReportUpdateHistory.find_by_month(@month)
   
   # layoutでヘッダを非表示
   @header_hidden = true
   
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
  
  # アタックリストメンテナンス
  def attack_list_maintenance
    
    @biru_trust_user = BiruUser.find(params[:sid])
    
    # 貸主の一覧を取得
    gon.buildings = ActiveRecord::Base.connection.select_all(get_buildings_sql(@biru_trust_user))    
    
    # 建物の一覧を取得
    gon.owners = ActiveRecord::Base.connection.select_all(get_owners_sql(@biru_trust_user, false))    
    
    # 委託契約の一覧を取得
    gon.trusts = ActiveRecord::Base.connection.select_all(get_trust_sql(@biru_trust_user, "", true))
    
    
    # layoutでヘッダを非表示
    @header_hidden = true
  end

  # アタックリスト一括メンテナンス
  def attack_list_maintenance_bulk
    @biru_trust_user = BiruUser.find(params[:sid])
    @header_hidden = true # ヘッダを非表示にする
  end
  
  # アタックリスト一括メンテナンス　貸主出力
  def attack_list_maintenance_bulk_owner_csv
    
    @biru_trust_user = BiruUser.find(params[:sid])
    @header_hidden = true # ヘッダを非表示にする
    data = ActiveRecord::Base.connection.select_all(get_owners_sql(@biru_trust_user, true))
    
    #-------------
    # CSV出力
    #-------------
    output_path = Rails.root.join( "tmp", "owner_list_.csv")
    
    header = ["貸主CD", "DM発行○×", "貸主名", "敬称", "カナ", "郵便番号", "住所", "電話番号", "メモ", "DM発行パターン１", "DM発行パターン２", "DM発行パターン３", "DM発行パターン４" ]
    csv_data = CSV.generate("", :headers => header, :write_headers => true) do |csv|
      data.each do |line|
        csv << line
      end
    end
    
    # 文字コード変換
    send_data csv_data, :filename=>'owner_list.csv'
    
  end
  
  # アタックリスト一括メンテナンス　取込み
  def attack_list_maintenance_bulk_owner_input
    
    @biru_trust_user = BiruUser.find(params[:sid])
    @header_hidden = true # ヘッダを非表示にする
    
    
    app_con = ApplicationController.new
    csv_text = params[:upload_file].read
    
    data = []

    #文字列をUTF-8に変換
    cnt = 0
    CSV.parse(Kconv.toutf8(csv_text)) do |row|
      
      if cnt == 0
        #---------------------------------------
        # 1行目の時はフォーマットチェック
        #---------------------------------------
        res, msg = format_check_owner(row)
        unless res
          flash[:danger] = msg
          break
        end
      else
        #---------------------------------------
        # 2行目以降であればデータ登録
        #---------------------------------------
        
        # ハッシュを生成
        name = Moji.han_to_zen(row[2].strip)
        address = Moji.han_to_zen((row[6].strip).tr("０-９", "0-9").gsub("－", "-"))
        hash = app_con.conv_code_owner(@biru_trust_user.id.to_s, address, name)
        dm = row[1]
        honorific_title = row[3]
        kana = row[4]
        postcode = row[5]
        tel = row[7]
        memo = row[8]
        ptn1 = row[9]
        ptn2 = row[10]
        ptn3 = row[11]
        ptn4 = row[12]
        
        # もしアタックコードがあれば、そこから現状のデータを取得
        if row[0] != nil  && row[0].length > 0
          id = row[0][2,10].to_i
          owner = Owner.where("biru_user_id = " + @biru_trust_user.id.to_s ).where("id = " + id.to_s).first
          unless owner
            
            # もしアタックコードが指定されていながらそのコードが存在しなければエラー
            flash[:danger] =  "登録エラー  " + cnt.to_s + "行目の　アタックCD:" + row[0] + "は存在しません"
            break
          end
          
        else
          
          # なければハッシュ（＝同一貸主名&住所）から検索　それでもなければ新規作成
          owner = Owner.unscoped.find_or_create_by_hash_key(hash)
          
          # IDを発番する為にsaveするが、その為にはgeocodeしている必要があるのでここで実施
          owner.address = address
          biru_geocode(owner, true)
          
  	      owner.save!
    			owner.attack_code = "OA%06d"%owner.id # 貸主idをattack_codeとする
          owner.save!

        end
        
        owner.hash_key = hash
  			owner.name = name
        owner.kana = kana
  			owner.honorific_title = honorific_title
  			owner.tel = tel
  			owner.biru_user_id = @biru_trust_user.id.to_s
        
        if dm == '○' then owner.dm_delivery = true else owner.dm_delivery = false end

        if ptn1 == '○' then owner.dm_ptn_1 = true else owner.dm_ptn_1 = false end
        if ptn2 == '○' then owner.dm_ptn_2 = true else owner.dm_ptn_2 = false end
        if ptn3 == '○' then owner.dm_ptn_3 = true else owner.dm_ptn_3 = false end
        if ptn4 == '○' then owner.dm_ptn_4 = true else owner.dm_ptn_4 = false end
        
  			owner.postcode = postcode
        if owner.address != address
          # 住所が違っていた時のみgeocodeもかける
          
          owner.address = address
          
          # geocode
          biru_geocode(owner, true)
        end
        
        owner.save!
        
      end

      cnt = cnt + 1
    end
    
    unless flash[:danger]
      # エラーが発生していない時は登録メッセージを設定
      flash[:notice] = (cnt-1).to_s + "件が処理されました。"
    end
    
    render 'attack_list_maintenance_bulk'
    
  end
  
  # owner一括取り込み　フォーマットチェック
  def format_check_owner(row)
    
    return false, "1列目が「attack_code」ではありません。" unless row[0] == 'attack_code'
    return false, "2列目が「dm」ではありません。" unless row[1] == 'dm'
    return false, "3列目が「name」ではありません。" unless row[2] == 'name'
    return false, "4列目が「honorific_title」ではありません。" unless row[3] == 'honorific_title'
    return false, "5列目が「kana」ではありません。" unless row[4] == 'kana'
    return false, "6列目が「postcode」ではありません。" unless row[5] == 'postcode'
    return false, "7列目が「address」ではありません。" unless row[6] == 'address'
    return false, "8列目が「tel」ではありません。" unless row[7] == 'tel'
    return false, "9列目が「memo」ではありません。" unless row[8] == 'memo'
    
    return true, ""
    
  end
  
  def attack_list_add
    
    # 指定された貸主CD、建物CD
    building_ids = params[:building_ids]
    owner_id = params[:owner_id]
    biru_user_id = params[:sid]
    
    reg_building_name = []
    
    # 選択された建物に対して委託の紐付けを行う。
    building_ids.split(",").each do |building_id|
      
      trust = Trust.unscoped.find_by_owner_id_and_building_id_and_biru_user_id(building_id, owner_id, biru_user_id )
      if trust
        trust.delete_flg = false
        reg_building_name.push(Building.find(building_id).name)
      else
        trust = Trust.new
        trust.building_id = building_id
        trust.owner_id = owner_id
        trust.delete_flg = false
      
        trust.biru_user_id = biru_user_id
  	  	trust.manage_type_id = ManageType.find_by_code('99').id # 管理外      
      
        reg_building_name.push(Building.find(building_id).name)
      end

      flash[:notice] = "貸主：" + Owner.find(owner_id).name + '  　建物：'
      reg_building_name.each do |building_nm|
        flash[:notice] = flash[:notice] + '【' + building_nm + '】、'
      end
      flash[:notice] = flash[:notice] + '　を【Dランク】で追加しました。'
    
      trust.save!
      
      
      # Dランクで履歴に登録
      pri_trust_attack_update(trust.id, get_cur_month, AttackState.find_by_code("X").id, AttackState.find_by_code("D").id, 0, nil, nil)
      
    end
    
    redirect_to :action => 'attack_list_maintenance', :sid=> params[:sid] 
  end
  
  
  # 委託契約の紐付けを行います。
  def create_trust
    
    # 指定された貸主CD、建物CD
    building_id = params[:building_id]
    owner_id = params[:owner_id]
    biru_user_id = params[:biru_user_id]
    
    reg_building_name = []
    
    # 選択された建物に対して委託の紐付けを行う。

    trust = Trust.unscoped.find_by_owner_id_and_building_id_and_biru_user_id(building_id, owner_id, biru_user_id )
    if trust
      trust.delete_flg = false
      reg_building_name.push(Building.find(building_id).name)
    else
      trust = Trust.new
      trust.building_id = building_id
      trust.owner_id = owner_id
      trust.delete_flg = false

      trust.biru_user_id = biru_user_id
    	trust.manage_type_id = ManageType.find_by_code('99').id # 管理外      

      reg_building_name.push(Building.find(building_id).name)
    end

    flash[:notice] = "貸主：" + Owner.find(owner_id).name + '  　建物：'
    reg_building_name.each do |building_nm|
      flash[:notice] = flash[:notice] + '【' + building_nm + '】、'
    end
    flash[:notice] = flash[:notice] + '　を【Dランク】で追加しました。'
    trust.save!

    # Dランクで履歴に登録
    pri_trust_attack_update(trust.id, get_cur_month, AttackState.find_by_code("X").id, AttackState.find_by_code("D").id, 0, nil, nil)
    
    redirect_to :action => 'popup_owner_buildings', :owner_id => owner_id
  end
  
  
  # 貸主登録
  def owner_regist
    @owner = Owner.new(params[:owner])
    begin
      
      # gmaps_ret = Gmaps4rails.geocode(@owner.address)
      # @owner.latitude = gmaps_ret[0][:lat]
      # @owner.longitude = gmaps_ret[0][:lng]
      # @owner.gmaps = true
      #
      
      @owner.name = Moji.han_to_zen(@owner.name)
      @owner.address = Moji.han_to_zen(@owner.address)
      
      hash = conv_code_owner(params[:owner][:biru_user_id],  @owner.address, @owner.name)
      if Owner.find_by_hash_key(hash)
        raise "この名前・住所は貸主一覧にすでに存在します。"
      end
      
      @owner.hash_key = hash
      @owner.save!
      @owner.attack_code = "OA%06d"%@owner.id
      @owner.save!
      
      flash[:notice] = "貸主：" + params[:owner][:name] + '  を貸主一覧に追加しました。'
    rescue => e
      flash[:danger] = e.to_s
      #flash[:danger] = "貸主の登録に失敗しました。存在する住所なのかを確認してください。"

    end
    # redirect_to :action => 'attack_list_maintenance', :sid=> params[:owner][:biru_user_id] 
    #     redirect_to :action => "popup_owner_create?owner_name=#{params[:owner][:owner_name]}&owner_address=#{params[:owner][:owner_address] }"

    redirect_to :action => 'popup_owner_create', :owner_name=> params[:owner][:name], :owner_address=>params[:owner][:address] 
  end
  
  
  # 建物登録
  def building_regist
    @building = Building.new(params[:building])
    begin
      
      @building.name = Moji.han_to_zen(@building.name)
      @building.address = Moji.han_to_zen(@building.address)
      
      hash = conv_code_building(params[:building][:biru_user_id],  @building.address, @building.name)
      if Building.find_by_hash_key(hash)
        raise "この名前・住所は建物一覧にすでに存在します。"
      end
      
      @building.hash_key = hash
      @building.save!
      @building.attack_code = "OA%06d"%@building.id
      @building.save!
      
      flash[:notice] = "建物：" + params[:building][:name] + '  を建物一覧に追加しました。'
    rescue => e
      flash[:danger] = e.to_s
    end
    #redirect_to :action => 'attack_list_maintenance', :sid=> params[:building][:biru_user_id] 
    redirect_to :action => 'popup_owner_buildings', :building_name=> @building.name, :owner_id=>params[:owner_id]
    
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

# bulk=> true:個別メンテ画面用, false:一括用
def get_owners_sql(object_user, bulk)
  
  if bulk
    
    sql = ""
    sql = sql + "SELECT id "
    sql = sql + ", a.attack_code "
    sql = sql + ", case a.dm_delivery  when 't' then '○' when 'f' then '×' else 'aa' end as dm "
    sql = sql + ", a.name "
    sql = sql + ", a.honorific_title "
    sql = sql + ", a.kana "
    sql = sql + ", a.postcode "
    sql = sql + ", a.address "
    sql = sql + ", a.tel "
    sql = sql + ", a.memo "
    sql = sql + ", case a.dm_ptn_1  when 't' then '○' when 'f' then '×' else 'aa' end as dm "
    sql = sql + ", case a.dm_ptn_2  when 't' then '○' when 'f' then '×' else 'aa' end as dm "
    sql = sql + ", case a.dm_ptn_3  when 't' then '○' when 'f' then '×' else 'aa' end as dm "
    sql = sql + ", case a.dm_ptn_4  when 't' then '○' when 'f' then '×' else 'aa' end as dm "
    sql = sql + "FROM owners a "
    sql = sql + "WHERE  biru_user_id = " + object_user.id.to_s + " "
    sql = sql + "AND a.delete_flg = 'f' "
    sql = sql + "ORDER BY updated_at DESC "
    
  else
    sql = ""
    sql = sql + "SELECT id "
    sql = sql + ", a.attack_code as code "
    sql = sql + ", a.name "
    sql = sql + ", a.address "
    sql = sql + ", a.memo "
    sql = sql + "FROM owners a "
    sql = sql + "WHERE  biru_user_id = " + object_user.id.to_s + " "
    sql = sql + "AND a.delete_flg = 'f' "
    sql = sql + "ORDER BY updated_at DESC "
  end
  
end

def get_buildings_sql(object_user)
  sql = ""
  sql = sql + "SELECT a.id "
  sql = sql + ", a.attack_code as code "
  sql = sql + ", a.name "
  sql = sql + ", a.address "
  sql = sql + ", a.memo "
  sql = sql + ", b.name as shop_name "
  sql = sql + "FROM buildings a inner join shops b on a.shop_id = b.id "
  sql = sql + "WHERE  biru_user_id = " + object_user.id.to_s + " "
  sql = sql + "AND a.delete_flg = 'f' "
  sql = sql + "ORDER BY updated_at DESC "
end

# 検索条件を初期化します。
def search_init

  # 検索条件の共通部分を呼び出します。
  search_init_common

  # 検索対象湯ユーザーを取得します
  @biru_users = get_attack_list_search_users(@biru_user)

  @search_param[:rank_s] = true
  @search_param[:rank_a] = true
  @search_param[:rank_b] = true
  @search_param[:rank_c] = true
  
end

# trust_user_report画面を開くにあたって、ログインユーザーがアタックリスト保持者当人もしくは権限ユーザーかチェックする
def check_report_auth(login_user, holder_user)
  
  # ログインユーザーとアクセス先画面のユーザーが同一ならtrue
  return true if login_user.id == holder_user.id
  
  # ログインユーザーに特権の権限があればtrue
  return true if login_user.attack_all_search == true
  
  # アクセス許可テーブルにログインユーザーが入っていればtrue
  if TrustAttackPermission.find_by_holder_user_id_and_permit_user_id(holder_user.id, login_user.id)
    return true
  end
  
  return false
end 


# 受託月報の見込み物件登録用
def report_rank_regist(month_report, trust_attack_history, start_date, end_date)
	
  attack_rank = TrustAttackMonthReportRank.unscoped.find_or_create_by_trust_attack_month_report_id_and_trust_id(month_report.id, trust_attack_history.trust_id)
  
  # trustの削除フラグがONになっていることもあるので、その場合はスキップする。
  unless trust_attack_history.trust
  	p 'report_rank_regist error: trust_attack_history_id :' + trust_attack_history.id.to_s  + ' 委託ID:' + trust_attack_history.trust_id.to_s 
  	return
  end
  
  attack_rank.trust_attack_month_report_id = month_report.id
  attack_rank.trust_id = trust_attack_history.trust_id
  attack_rank.owner_id = trust_attack_history.trust.owner.id
  attack_rank.change_month = trust_attack_history.month
  attack_rank.attack_state_this_month_id = trust_attack_history.attack_state_to.id
  
  # 先月のランクを取得する。(存在しない時は、最新のランクと変わっていないということなので今月時点の最新ランクを設定する)
  last_month = (Date.strptime(month_report.month + "01", "%Y%m%d") << 1).strftime("%Y%m")
  last_month_state = TrustAttackStateHistory.find_by_trust_id_and_month(trust_attack_history.trust_id, last_month)
  if last_month_state
    attack_rank.attack_state_last_month_id = last_month_state.attack_state_to.id
  else
    
    # もし過去のランクが１件も存在しなければ、当初は未設定ということ。そうでなければそれ以降の変更がないということで今月時点の最新ランクを設定する
    if TrustAttackStateHistory.where("trust_id = " + trust_attack_history.trust_id.to_s + " and month < '" + last_month + "'").count == 0
      attack_rank.attack_state_last_month_id = AttackState.find_by_code("X").id
    else
      attack_rank.attack_state_last_month_id = trust_attack_history.attack_state_to.id
    end
    
  end
  
  attack_rank.change_status = AttackState.compare_rank(attack_rank.attack_state_last_month, attack_rank.attack_state_this_month)
  
  building = trust_attack_history.trust.building

  attack_rank.building_id = building.id
  attack_rank.building_name = building.name
  
  attack_rank.building_latitude = building.latitude
  attack_rank.building_longitude = building.longitude
  
  # 当月にその見込み物件オーナーにアプローチした件数をカウント(DM除く)
   attack_rank.approach_cnt =  OwnerApproach.joins(:approach_kind).where("owner_approaches.owner_id = " + attack_rank.owner_id.to_s ).where("approach_date between ? and ? ", start_date, end_date).where("biru_user_id = ?", month_report.biru_user_id).where("approach_kinds.code in ('0010', '0020', '0025', '0040', '0045')").count
   
  
  
  attack_rank.delete_flg = false
  attack_rank.save!

end


end