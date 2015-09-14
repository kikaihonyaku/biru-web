#-*- encoding:utf-8 -*- 
#require 'nokogiri'
require 'open-uri'
class ManagementsController < ApplicationController

  before_filter :init_managements

  def init_managements

    # 建物名・住所
    @building_nm = ""
    @building_ad = ""

    # 営業所指定
    @shop_checked = {}
    @shop_checked[:tobu01] = false
    @shop_checked[:tobu02] = false
    @shop_checked[:tobu03] = false
    @shop_checked[:tobu04] = false
    @shop_checked[:tobu05] = false
    @shop_checked[:tobu06] = false
    @shop_checked[:tobu07] = false
    @shop_checked[:tobu08] = false
    @shop_checked[:sai01] = false
    @shop_checked[:sai02] = false
    @shop_checked[:sai03] = false
    @shop_checked[:sai04] = false
    @shop_checked[:sai05] = false
    @shop_checked[:sai06] = false
    @shop_checked[:sai07] = false
    @shop_checked[:sai08] = false
    @shop_checked[:sai09] = false
    
    @shop_checked[:chiba01] = false
    @shop_checked[:chiba02] = false
    @shop_checked[:chiba03] = false
    @shop_checked[:chiba04] = false

    # 物件種別指定
    @build_type_checked = {}
    @build_type_checked[:apart] = false
    @build_type_checked[:man] = false
    @build_type_checked[:bman] = false
    @build_type_checked[:tenpo] = false
    @build_type_checked[:jimusyo] = false
    @build_type_checked[:kojo] = false
    @build_type_checked[:soko] = false
    @build_type_checked[:kodate] = false
    @build_type_checked[:terasu] = false
    @build_type_checked[:mezo] = false
    @build_type_checked[:ten_jyu] = false
    @build_type_checked[:soko_jimu] = false
    @build_type_checked[:kojo_soko] = false
    @build_type_checked[:syakuti] = false

    # 管理方式指定
    @manage_type_checked = {}
    @manage_type_checked[:kanri_i] = false
    @manage_type_checked[:kanri_a] = false
    @manage_type_checked[:kanri_b] = true
    @manage_type_checked[:kanri_c] = true
    @manage_type_checked[:kanri_d] = true
    @manage_type_checked[:kanri_soumu] = true
    @manage_type_checked[:kanri_toku] = true
    @manage_type_checked[:kanri_teiki] = true
    @manage_type_checked[:kanri_gyoumu] = true
#    @manage_type_checked[:kanri_gai] = false

    # オブジェクトの初期化
    @buildings = []
    @shops = []
    @owners = []
    @trusts = []
    @owner_to_buildings = []

    # 貸主名・住所
    @owner_nm = ""
    @owner_ad = ""

    # 検索種別（建物検索：１　貸主検索：２）
    @search_type = 1

    # バルク検索用の文字列
    @bulk_text = ""

    # タブ表示
    @tab_search = "active in"
    @tab_result = ""

    # 自社・他社種別
#    @ji_only_flg = true
#    @ta_only_flg = false
#    @jita_both_flg = false
    
    @search_bar_disp_flg = true
    
  end

  # オーナー情報確認用のwindowを表示します。
  def popup_owner
    get_popup_owner_info(params[:id])
    @cur_month = get_month(Date.today)
    
    dt_base = Date.parse(@cur_month + '01', "YYYYMMDD").months_ago(3)
    
		@calender = []
    5.times{
      @calender.push([dt_base.strftime("%Y/%m"), dt_base.strftime("%Y%m") ])
      dt_base = dt_base.next_month
    }
    
    # 建物とアタックの状況を取得
    @biru_and_state = []
    @owner.trusts.each do |trust|
      if trust.building
        # 先月以前のアタック状況を取得
        before_max_month =  TrustAttackStateHistory.where("month < ?", @cur_month).where("trust_id = ?", trust.id ).maximum("month")
        if before_max_month
          # アタック状況が登録されている時、その最新の日付から先月以前の最新の見込み状況を取得する
          before_attack_state = TrustAttackStateHistory.where("month = ?", before_max_month).where("trust_id = ?", trust.id).first.attack_state_to
        else
          # アタック状況が登録されていない時
          before_attack_state = AttackState.find_by_code("X")
        end

        # 現時点で最新のアタック状況を取得
        current_max_month =  TrustAttackStateHistory.where("trust_id = ?", trust.id ).maximum("month")
        if current_max_month
          # アタック状況が登録されている時、その最新の日付から先月以前の最新の見込み状況を取得する
          current_attack_state = TrustAttackStateHistory.where("month = ?", current_max_month).where("trust_id = ?", trust.id).first.attack_state_to
        else
          # アタック状況が登録されていない時
          current_attack_state = AttackState.find_by_code("X")
        end
        
        # 現在月で契約情報が登録されていたらそれも取得する。
        this_month_trust = {
          :room_num=>0,
          :manage_type_id=>0,
          :trust_oneself=>false
        }
        
        this_month_history = TrustAttackStateHistory.where("month = ?", @cur_month).where("trust_id = ?", trust.id).first
        if this_month_history 
          this_month_trust[:room_num] = this_month_history.room_num
          this_month_trust[:manage_type_id] = this_month_history.manage_type_id
          this_month_trust[:trust_oneself] = this_month_history.trust_oneself
        end
        
        # 建物、先月以前のアタック状況、最新のアタック状況を設定
        @biru_and_state.push([trust, trust.building, before_attack_state, current_attack_state, this_month_trust])
      end
    end
    
    render :layout => 'popup'
  end

  # オーナー情報の登録をポップアップから行います。
  def popup_owner_update
    
    @owner = Owner.find(params[:id])
    
    # 2015/07/24 登録はハッシュなどを登録するので登録は個別に行う
    # @owner.gmaps = false # 住所の設定をさせる為に設定
    # if @owner.update_attributes(params[:owner])
    # end
    
    
    # アドレスを後の判断に使用するので退避
    backup_address = @owner.address 
    
    # 登録する項目を設定
    @owner.name = Moji.han_to_zen(params[:owner][:name].strip)
    @owner.address = Moji.han_to_zen(params[:owner][:address].strip).tr("０-９", "0-9").gsub("－", "-")
    @owner.kana = params[:owner][:kana]
    @owner.honorific_title = params[:owner][:honorific_title]
    @owner.postcode = params[:owner][:postcode]
    @owner.tel = params[:owner][:tel]
    
    @owner.dm_delivery = params[:owner][:dm_delivery]
    @owner.dm_ptn_1 = params[:owner][:dm_ptn_1]
    @owner.dm_ptn_2 = params[:owner][:dm_ptn_2]
    @owner.dm_ptn_3 = params[:owner][:dm_ptn_3]
    @owner.dm_ptn_4 = params[:owner][:dm_ptn_4]
    
    app_con = ApplicationController.new
    @owner.hash_key = app_con.conv_code_owner(@owner.biru_user_id.to_s, @owner.address, @owner.name)
    
    # 住所に変更があったらgeocodeで再計算
    unless @owner.address == backup_address
      biru_geocode(@owner, true)
    end
    
    
    @owner.save!

    # render :action=>'popup_owner', :layout => 'popup'
    redirect_to :action=>'popup_owner', :id=>@owner.id
  end
  
  # アプローチ履歴を登録する
  def owner_approach_regist 
    @owner_approach = OwnerApproach.new(params[:owner_approach])
    @owner_approach.save!
    redirect_to :controller=>'managements', :action => 'popup_owner', :id => params[:owner_approach][:owner_id].to_i
  end
  
  # アプローチリレキを削除する
  def owner_approach_delete
    owner_approach = OwnerApproach.find(params[:id].to_i)
    owner_approach.delete_flg = true
    owner_approach.save!
    
    redirect_to :action=>'popup_owner', :id=>params[:owner_id]
  end
  
  def get_popup_owner_info(id)
    @owner = Owner.find(id)
    gon.owner = @owner
    @owner_approaches = initialize_grid(OwnerApproach.joins(:owner).includes(:biru_user, :approach_kind).where(:owner_id => @owner).order("approach_date desc") )
    
    if @owner.trusts
      buildings = []
      
      @owner.trusts.each do |trust|
        buildings.push(trust.building) if trust.building
      end
      gon.buildings = buildings
      
    end
  end
  
  
  # ファイル保存
  def popup_owner_documents_regist
    
    @owner = Owner.find(params[:owner_id])
    
    document = Document.new
    document.owner_id = @owner.id
    document.biru_user_id = @biru_user.id
    
    file = params[:doc_file]
    
    if file.size > 100.megabyte
      raise "ファイルサイズが100MBを超えています。" 
    end
    
    document.file_name = file.original_filename
  
    # パス存在チェック。無ければ作成
    path = "public/documents/owner/" + sprintf("%08d", @owner.id)
    FileUtils.mkdir_p(path) unless FileTest.exist?(path)
  
    # ファイルをコピー
    File.open( path + "/#{document.file_name}", 'wb') { |f|
      f.write(file.read)
    }
    
    document.save!
    
    redirect_to :action=>'popup_owner', :id=>@owner.id
  end
  
  # ファイルダウンロード
  def popup_owner_documents_download
    
    @doc = Document.find(params[:document_id])

    hash = Rails.application.routes.recognize_path(request.referrer)
    if hash[:action] != 'popup_owner'
      raise "遷移もとが不正です。" + hash[:action] 
    end
      
    path = "public/documents/owner/" + sprintf("%08d", @doc.owner.id) + '/' + @doc.file_name
    
    stat = File::stat(path)
    send_file(path, :filename => @doc.file_name, :length => stat.size)    
  end

  # 建物情報確認用のwindowを表示する。
  def popup_building
    @building = Building.find(params[:id])
    gon.building = @building
    @trust = Trust.find_by_building_id(@building)
    
    # レンターズAPIをコールする
#    url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&room_cd=7527190")
#    xml = open(url).read
#    doc = Nokogiri::XML(xml)
#    @ssss = doc.xpath('/results/room/picture/true_url').first.inner_text
    
    render :layout => 'popup'


#    open(url) do |http|
#      response = http.read
#      @xml =  "response: #{response.inspect}"
#    end
    
  end

  def popup_building_update
    @building = Building.find(params[:id])

    if @building.update_attributes(params[:building])
    end

    #render :action=>'popup_building', :layout => 'popup'
    redirect_to :action=>'popup_building', :id=>@building.id
  end
  
  # 建物情報画面から委託契約の更新
  def popup_building_trust_update
    
    pri_trust_attack_update
    redirect_to :action=>'popup_building', :id=>@trust.building_id
  end
  

  def index

    # 営業所のみ表示 (検索結果一覧リストに出すために、インスタンス変数にも入れる)
    @shops = Shop.find(:all)
    gon.shops = @shops
    gon.buildings = @buildings
    gon.trusts = @trusts
    gon.owners = @owners
    gon.all_shops = Shop.find(:all)
    
    # 検索バー非表示
    @search_bar_disp_flg = true
    if params[:search_bar]
      if params[:search_bar] == 'none'
        @search_bar_disp_flg = false
      end
    end
    
  end

  # 貸主検索
  def search_owners

    search_result_init(2) # 貸主を初期表示

    # 元データを取得
    tmp_owners = Owner.oneself.scoped
    tmp_owners = tmp_owners.joins(:trusts => :building).scoped

    # 貸主名の絞り込み
    word = params[:owner_name]
    if word.length > 0
      tmp_owners = tmp_owners.where("owners.name like ?", "%#{word}%")
      @owner_nm = word
    end

    # 住所の絞り込み
    address = params[:owner_address]
    if address.length > 0
      tmp_owners = tmp_owners.where("owners.address like ?", "%#{address}%")
      @owner_ad = address
    end

    # 絞り込んだ貸主から、建物の配列を取得する
    @buildings = []
    tmp_owners.group("buildings.id").select("buildings.id").each do |id|
      biru = Building.find_by_id(id)
      @buildings << biru if biru
    end

    if @buildings
      buildings_to_gon(@buildings)
    end

    render 'index'

  end

  # 物件検索
  def search_buildings

    search_result_init(1) # 建物を初期表示

    # 自社物件のみを対象とする
    tmp_buildings = Building.oneself.scoped
    tmp_buildings = tmp_buildings.includes(:build_type)
    tmp_buildings = tmp_buildings.includes(:shop)
    tmp_buildings = tmp_buildings.includes(:trusts)
    tmp_buildings = tmp_buildings.includes(:trusts => :owner)

    # 建物名の絞り込み
    if params[:biru_name]
	    word = params[:biru_name]
	    if word.length > 0
	      tmp_buildings = tmp_buildings.where("buildings.name like ?", "%#{word}%" )
	      @building_nm = word
	    end
    end
  
		if params[:biru_address]
	    address = params[:biru_address]
	    if address.length > 0
	      tmp_buildings = tmp_buildings.where("buildings.address like ?", "%#{address}%" )
	      @building_ad = address
	    end
		end

    # 営業所チェックボックスが選択されていたら、それを絞り込む
    if params[:shop]

      shop_arr = []
      params[:shop].keys.each do |key|
        shop_arr.push(Shop.find_by_code(params[:shop][key]).id)
        @shop_checked[key.to_sym] = true
      end
      tmp_buildings = tmp_buildings.where(:shop_id=>shop_arr)
    end

    # 物件種別で絞り込み
    if params[:build_type]
      build_type = []
      params[:build_type].keys.each do |key|
        build_type.push(BuildType.find_by_code(params[:build_type][key]).id)
        @build_type_checked[key.to_sym] = true
      end
      tmp_buildings = tmp_buildings.where(:build_type_id=>build_type)
    end


    # 管理方式で絞り込み
    if params[:manage_type]

      # ↓2014/08/12 自社管理物件のみ対象にするのでコメントアウト
      # ji_flg = false # 自社カウント
      # ta_flg = false # 他社カウント
      
      manage_type = []
      
      # 一度すべて未チェックで初期化
      @manage_type_checked.keys.each do |manage_type_check|
        @manage_type_checked[manage_type_check] = false
      end
      
      params[:manage_type].keys.each do |key|
        manage_type.push(ManageType.find_by_code(params[:manage_type][key]).id)
        @manage_type_checked[key.to_sym] = true

        # ↓2014/08/12 自社管理物件のみ対象にするのでコメントアウト
        # if key.to_sym == :kanri_gai
        #   ta_flg = true # 管理外の時
        # else
        #   ji_flg = true # 通常の管理方式の時
        # end
      end

      # ↓2014/08/12 自社管理物件のみ対象にするのでコメントアウト
      # # 自社他社ラジオボタン判定
      # if ji_flg == true && ta_flg == true
      #   # 自社と他社のどちらも選択された時
      #   @ji_only_flg = false
      #   @ta_only_flg = false
      #   @jita_both_flg = true
      #
      # else
      #   if ji_flg == true
      #     # 自社のみ選択
      #     @ji_only_flg = true
      #     @ta_only_flg = false
      #     @jita_both_flg = false
      #
      #   else
      #
      #     # 他社のみ選択
      #     @ji_only_flg = false
      #     @ta_only_flg = true
      #     @jita_both_flg = false
      #
      #   end
      # end

      # ここでInner Joinをして管理方式が存在するもののみを絞り込む
      tmp_buildings = tmp_buildings.where("trusts.manage_type_id"=>manage_type)
    else
      # 管理方式がひとつも選択されていない時は、種別は両方を設定
      # @ji_only_flg = false
      # @ta_only_flg = false
      # @jita_both_flg = true
    end

    # 物件情報を出力
    if tmp_buildings
      buildings_to_gon(tmp_buildings)
    end

    render 'index'

  end

  # 物件種別のiconを変更する時のコントローラ
  def change_biru_icon
    # p 'パラメータ ' + params[:disp_type].to_s
    @biru_icon = params[:disp_type]
  end


  #########################
  # ファイル一括検索を行います。
  #########################
  def bulk_search_text
    search_result_init(1) # 建物を初期表示

    @bulk_text = params[:bulk_search_text]
    buildings_to_gon(parse_buildings(@bulk_text))
    render 'index'
  end

  def bulk_search_file
    search_result_init(1) # 建物を初期表示

    buildings_to_gon(parse_buildings(params[:file].read))
    render 'index'
  end

  # 文字列から建物情報を作成する
  def parse_buildings(str)
    buildings = []
    codes = []

    # 改行・タブ・「、」は全て「,」にする。
    str.gsub("、",",").gsub(/(\r\n|\r|\n)/, ",").gsub(/\t/,",").split(",").each do |code|
      if code.length > 0
        codes << code
      end
    end

    if codes.length > 0
      buildings = Building.where(:code=>codes)
    end

    return buildings
    
  end
end

