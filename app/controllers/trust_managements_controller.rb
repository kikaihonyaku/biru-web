#-*- encoding:utf-8 -*-

require 'kconv'
require 'thinreports'

class TrustManagementsController < ApplicationController
  
  before_filter :search_init, :except => ['trust_user_report']

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
    TrustAttackMonthReportAction.delete_all(['trust_attack_month_report_id = ? ', report.id])
    OwnerApproach.joins(:approach_kind).where("approach_date between ? and ? ", start_date, end_date).where("biru_user_id = ?", user.id).select("owner_approaches.owner_id, approach_kinds.code, owner_approaches.id as approach_id").each do |rec|
  	
      attack_action = TrustAttackMonthReportAction.new
      attack_action.trust_attack_month_report_id = report.id
      attack_action.owner_approach_id = rec.approach_id
      
      # attack_action.biru_user_id = user.id
      # attack_action.month = month
      # attack_action.owner_id = rec.owner
      # attack_action.content = rec.content
      # attack_action.approach_date = rec.approach_date
      # attack_action.approach_kind_id = rec.approach_kind_id
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
        tel_num_call = tel_num_call + 1
  	
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
    
    rank_s_trusts = []
    rank_a_trusts = []
    rank_b_trusts = []
    rank_c_trusts = []
    rank_z_trusts = []
    

    buildings = []
    order_hash = TrustAttackStateHistory.joins(:trust).joins(:attack_state_to).where("month <= ?", month).where("trusts.biru_user_id = ?", user.id).group("trusts.id").maximum("month")
    order_hash.keys.each do |trust_id|

      # trust_idにはidが、order_hash[trust_id]にはその月の最大月数が入っている
      trust_attack_history = TrustAttackStateHistory.find_by_trust_id_and_month(trust_id, order_hash[trust_id])

      # ↓見込みランクの絞り込みはクエリのwhere句の中でなく、集計結果に対して行う。
      # where句でやるとそのランクがある中での最大をとってしまうので、仮にその後に別のランクが登録されていたら本来は必要ないのにそのレコードがとれてしまうから
      case trust_attack_history.attack_state_to.code
      when 'S', 'A', 'B'

        if trust_attack_history.trust
          biru = trust_attack_history.trust.building
          biru.tmp_manage_type_icon = trust_attack_history.attack_state_to.code
          biru.tmp_build_type_icon = trust_attack_history.attack_state_to.icon
          buildings << biru
        end
      

      when 'Z'
        # 成約になった物件は、当月のみ表示対象
        
        if trust_attack_history.month.to_s == month.to_s
          
          biru = trust_attack_history.trust.building
          biru.tmp_manage_type_icon = trust_attack_history.attack_state_to.code
          biru.tmp_build_type_icon = trust_attack_history.attack_state_to.icon
          buildings << biru

          # 受託実績戸数を入力
          if trust_attack_history.trust_oneself == true
            
            trust_num_oneself = trust_num_oneself + trust_attack_history.room_num
          else
            trust_num = trust_num + trust_attack_history.room_num
          end

        end

      else
      end

      case trust_attack_history.attack_state_to.code
      when 'S' then
        rank_s = rank_s + 1
        rank_s_trusts << trust_id
      when 'A' then
        rank_a = rank_a + 1
        rank_a_trusts << trust_id
      when 'B' then
        rank_b = rank_b + 1
        rank_b_trusts << trust_id
      when 'C' then
        rank_c = rank_c + 1
        rank_c_trusts << trust_id
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
        rank_z_trusts << trust_id
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
  
  #  report.suggestion_plan = biru_user_monthly.trust_plan_suggestion
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
  
    # ID一覧の設定
    # report.visit_owners_absence = visit_owners_absence.join(',')
    # report.visit_owners_meet = visit_owners_meet.join(',')
    # report.visit_owners_suggestion = visit_owners_suggestion.join(',')
    # report.dm_owners_send = dm_owners_send.join(',')
    # report.dm_owners_recv = dm_owners_recv.join(',')
    # report.tel_owners_call = tel_owners_call.join(',')
    # report.tel_owners_talk = tel_owners_talk.join(',')
    #
    # report.rank_s_trusts = rank_s_trusts.join(',')
    # report.rank_a_trusts = rank_a_trusts.join(',')
    # report.rank_b_trusts = rank_b_trusts.join(',')
    # report.rank_c_trusts = rank_c_trusts.join(',')
    # report.rank_z_trusts = rank_z_trusts.join(',')
  
    # 全件数を取得する
    sql = ""
    sql = sql + "SELECT count(*) as cnt "
    sql = sql + "FROM (" + get_trust_sql(user, "", false) + ") X "
    sql = sql + "where biru_user_id = " + user.id.to_s
    ActiveRecord::Base.connection.select_all(sql).each do |all_cnt_rec|
      report.rank_all = all_cnt_rec['cnt']
    end
  
    report.save!

  end  
  

  #def get_trust_data()
  def get_trust_sql(object_user, rank_list, order_flg)
  
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
    sql = sql + " , owners.address as owner_address "
    sql = sql + " , owners.memo as owner_memo "
    sql = sql + " , owners.latitude as owner_latitude "
    sql = sql + " , owners.longitude as owner_longitude "
    sql = sql + " , owners.dm_delivery as owner_dm_delivery "
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
    # 検索条件が指定されている時の絞り込み
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
      sql = sql + " ORDER BY buildings.id asc"
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
    trust_user_hash = {} 
    trust_user_hash['6365'] = {:name=>'松本', :shop_name => '草加'}
    trust_user_hash['6487'] = {:name=>'氏家', :shop_name => '草加新田'}
    trust_user_hash['5952'] = {:name=>'山口', :shop_name => '北千住'}
    
    trust_user_hash['6464'] = {:name=>'猪原', :shop_name => '南越谷'}
    trust_user_hash['6406'] = {:name=>'末吉', :shop_name => '越谷'}
    trust_user_hash['6425'] = {:name=>'赤坂', :shop_name => '北越谷'}
#    trust_user_hash['xxxx'] = {:name=>'xxx', :shop_name => '春日部'}

    trust_user_hash['5684'] = {:name=>'帰山', :shop_name => 'せんげん台'}

    trust_user_hash['6461'] = {:name=>'中野', :shop_name => '戸田公園'}
    trust_user_hash['7844'] = {:name=>'辻', :shop_name => '戸田'}
#    trust_user_hash['xxxx'] = {:name=>'xxx', :shop_name => '武蔵浦和'}

    trust_user_hash['6338'] = {:name=>'鈴木', :shop_name => '川口'}
    trust_user_hash['5313'] = {:name=>'宮川', :shop_name => '与野'}

#    trust_user_hash['xxx'] = {:name=>'xxx', :shop_name => '浦和'}

    trust_user_hash['5473'] = {:name=>'小泉', :shop_name => '東浦和'}
    trust_user_hash['5841'] = {:name=>'下地', :shop_name => '戸塚安行'}
    trust_user_hash['4917'] = {:name=>'市橋', :shop_name => '千葉支店'}
    trust_user_hash['5928'] = {:name=>'柴田', :shop_name => 'テスト'}
    trust_user_hash['5000'] = {:name=>'東武北エリア', :shop_name => 'テスト'}

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

    
    gon.data_list = user_list

  end
  
  
  def owner_building_list
  	
  	# 権限チェック。権限がない人は自分の物件しか見れない
  	unless params[:sid]
  		@error_msg = "パラメータが不正です。"
    else
    	
    	@object_user = BiruUser.find(params[:sid].to_i)
    	unless @object_user
	  		@error_msg = "指定されたユーザーが存在しません。"
      else
      	if @biru_user.attack_all_search == false && @biru_user.id != @object_user.id
		  		@error_msg = "自分以外のアタックリストにアクセスすることはできません。"
      	end
      	
    	end
    	
  	end
    
    # 見込みランクの指定
    rank_arr = ""
    if params[:rank]
      params[:rank].split(',').each do |value|
        
        if rank_arr.length > 0
          rank_arr = rank_arr + ','
        end
        
        rank_arr = rank_arr + "'" + value + "'"
        
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
      
      ActiveRecord::Base.connection.select_all(get_trust_sql(@object_user, rank_arr, true)).each do |rec|
        
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
    #result = get_report_info(@month, @biru_trust_user)
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
   grid_data = []
   approach_owners = []
   check_owner = {}
   
   @report.trust_attack_month_report_actions.each do |action_rec|
   
     owner_approach = action_rec.owner_approach
     owner_rec = owner_approach.owner
   
     case owner_approach.approach_kind.code
     when '0010', '0020' # 訪問
       icon = '/assets/marker_blue.png'
     when '0030', '0035' # ＤＭ
       icon = '/assets/marker_green.png'
     when '0040', '0045' # 電話
       icon = '/assets/marker_orange.png'
     when '0025' # 提案
       icon = '/assets/marker_red.png'
     else
       icon = '/assets/marker_gray.png'
     end
   
     # 地図へ表示するアイコンの情報
     approach_owner = {
         :id=>owner_rec.id, :name=>owner_rec.name, :latitude=>owner_rec.latitude, :longitude=>owner_rec.longitude, :icon=>icon
     }
   
     unless check_owner[approach_owner[:id]]
       approach_owners.push(approach_owner)
       check_owner[approach_owner[:id]] = true
     end     
   
     # アプローチ種別が面談・電話会話・DM反響・提案の時のみ行動詳細に表示
     case owner_approach.approach_kind.code
     when '0020', '0035', '0045', '0025'
       # jqgridに表示する一覧の情報(訪問の面談・提案・TELの応答のみ表示。それ以外は対象外)
       row_data = {}
       row_data[:owner_id] = owner_approach.owner_id
       row_data[:approach_kind] = owner_approach.approach_kind.name
       row_data[:approach_date] = owner_approach.approach_date
       row_data[:approach_content] = owner_approach.content
       row_data[:owner_code] = owner_approach.owner.code
       row_data[:owner_name] = owner_approach.owner.name
       row_data[:owner_address] = owner_approach.owner.address

       grid_data.push(row_data)
     end
   end
   
   gon.grid_data = grid_data
   gon.approach_owners = approach_owners
   
   # layoutでヘッダを非表示
   @header_hidden = true
   
   # 一覧をしぼったコンボボックスの表示
   result = ":"
   ApproachKind.where("code in ('0020', '0035', '0045', '0025')").order(:sequence).each do |obj|
     result = result + ";" + obj.name + ":" + obj.name
   end
   result
      
   @combo_approach_kinds = result
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
    gon.owners = ActiveRecord::Base.connection.select_all(get_owners_sql(@biru_trust_user))    
    
    # 委託契約の一覧を取得
    gon.trusts = ActiveRecord::Base.connection.select_all(get_trust_sql(@biru_trust_user, "", true))
    
    
    # layoutでヘッダを非表示
    @header_hidden = true
  end
  
  def attack_list_add
    
    # 指定された貸主CD、建物CD
    building_id = params[:building_id]
    owner_id = params[:owner_id]
    biru_user_id = params[:sid]
    
    trust = Trust.unscoped.find_by_owner_id_and_building_id_and_biru_user_id(building_id, owner_id, biru_user_id )
    if trust
      trust.delete_flg = false
      flash[:notice] = 'すでに削除済みとして登録されていたアタックリストを復活しました。'
    else
      trust = Trust.new
      trust.building_id = building_id
      trust.owner_id = owner_id
      trust.delete_flg = false
      
      trust.biru_user_id = biru_user_id
	  	trust.manage_type_id = ManageType.find_by_code('99').id # 管理外      
      
      flash[:notice] = "貸主：" + Owner.find(owner_id).name + '  　建物：' + Building.find(building_id).name + '　をアタックリストに追加しました。'
    end
    
    trust.save!
    redirect_to :action => 'attack_list_maintenance', :sid=> params[:sid] 
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
    redirect_to :action => 'attack_list_maintenance', :sid=> params[:owner][:biru_user_id] 
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
    redirect_to :action => 'attack_list_maintenance', :sid=> params[:building][:biru_user_id] 
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

def get_owners_sql(object_user)
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