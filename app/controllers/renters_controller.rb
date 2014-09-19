#-*- encoding:utf-8 -*-
require 'open-uri' # open関数でurlを読み込む為に必要
require 'rexml/document'

class RentersController < ApplicationController
  
  respond_to :html, :json
  
  def index
    @data_update = DataUpdateTime.find_by_code("310")
    
    index_columns ||= [:id]

    current_page  = params[:page] ? params[:page].to_i : 1
    rows_per_page = params[:rows] ? params[:rows].to_i : 10

    conditions={:page => current_page, :per_page => rows_per_page}
    #conditions[:order] = params["sidx"] + " " + params["sord"] unless (params[:sidx].blank? || params[:sord].blank?)

    #if params[:_search] == "true"
    #  conditions[:conditions]=filter_by_conditions(index_columns)
    #end

   # @renters_buildings = RentersBuilding.paginate(conditions)
    @renters_buildings = RentersBuilding.all
    total_entries=@renters_buildings.count

    respond_with(@renters_buildings) do |format|
     format.json { render :json => @renters_buildings.to_jqgrid_json(index_columns, current_page, rows_per_page, total_entries)}
    end
    
  end
  
  # 画像一覧を表示します
  def pictures
    @room = Room.find(params[:id])
    @room_renters = RentersRoom.find(@room.renters_room_id)
    
  end
  
  
  # 管理物件からレンターズの登録内容を更新取得します。
  def update_all

    @data_update = DataUpdateTime.find_by_code("310")
    @data_update.start_datetime = Time.now
    @data_update.update_datetime = nil
    @data_update.biru_user_id = @biru_user.id
    @data_update.save!

    # バッチIDを生成
    batch_cd = Time.now.strftime('%Y%m%d%H%M%S')
    
    # レンターズデータの取得
    renters_get_data(batch_cd)

    # 取得データを展開
    renters_reflect(batch_cd)
  
    @data_update.update_datetime = Time.now
    @data_update.save!
    
    render 'index'
    
  end
  
  # レンターズデータを本番に反映する
  def renters_reflect(batch_cd)
    
    RentersRoom.update_all("delete_flg = ?", true)
    RentersBuilding.update_all("delete_flg = ?", true)
    
    # renters_roomへの反映
    WorkRentersRoom.where("batch_cd = ?", batch_cd).each do |work_room|
      
      room = RentersRoom.find_or_create_by_room_code(work_room.room_cd)
      room.room_code = work_room.room_cd
      room.building_code = work_room.building_cd
      room.clientcorp_room_cd = work_room.clientcorp_room_cd
      room.clientcorp_building_cd = work_room.clientcorp_building_cd
      room.store_code = work_room.store_code
      room.store_name = work_room.store_name
      room.building_name = work_room.building_name
      room.room_no = work_room.room_no
      room.real_building_name = work_room.real_building_name
      room.real_room_no = work_room.real_room_no
      room.floor = work_room.floor
      room.building_type = work_room.building_type
      room.structure = work_room.structure
      room.construction = work_room.construction
      room.room_num = work_room.room_num
      room.address = work_room.address
      room.detail_address = work_room.detail_address
      room.vacant_div = work_room.vacant_div
      room.enter_ym = work_room.enter_ym
      room.new_status = work_room.new_status
      room.completion_ym = work_room.completion_ym
      room.square = work_room.square
      room.room_layout_type = work_room.room_layout_type
      room.delete_flg = false
      room.save!
      
    end
    
    # renters_buildingへの反映
    WorkRentersRoom.where("batch_cd = ?", batch_cd).group("building_cd, clientcorp_building_cd, store_code, store_name, building_name, real_building_name, building_type, structure, address, detail_address").select("building_cd, clientcorp_building_cd, store_code, store_name, building_name, real_building_name, building_type, structure, address, detail_address").each do |work_building|

      building = RentersBuilding.find_or_create_by_building_cd(work_building.building_cd)
      building.building_cd = work_building.building_cd
      building.clientcorp_building_cd = work_building.clientcorp_building_cd

      #building.store_code = work_building.store_code
      #building.store_name = work_building.store_name
      building.building_name = work_building.building_name
      building.real_building_name = work_building.real_building_name
      building.building_type = work_building.building_type
      building.structure = work_building.structure
      building.address = work_building.detail_address
      
      # geocode
      gmaps_ret = Gmaps4rails.geocode(building.address)
      building.latitude = gmaps_ret[0][:lat]
      building.longitude = gmaps_ret[0][:lng]
      building.gmaps = true

      building.delete_flg = false
      building.save!
    end
    
  end
  
  # レンターズデータをworkテーブルに取得します
  def renters_get_data(batch_cd)
    
    get_cnt = 50
    start_idx = 1
    
    loop do
      
      url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&count=#{get_cnt.to_s}&start=#{start_idx.to_s}")
      xml = open(url).read
      doc = REXML::Document.new(xml)
      
      # １件も取得できなかったら終了
      ret_status = doc.elements['results/results_returned']
      break unless ret_status
      break if ret_status.text == "0"

      # 次の取得の準備
      start_idx = start_idx + get_cnt
      
      break if start_idx > 500
      
      # 配列がなくなるまで建物・部屋を作成
      doc.elements.each_with_index('results/room') do |room, i|
        p room.elements['room_cd'].text
        
        # レンターズ 部屋情報の取得
        work_renters_room = WorkRentersRoom.create
        work_renters_room.batch_cd = batch_cd
        work_renters_room.batch_cd_idx = start_idx + i
        work_renters_room.room_cd = room.elements['room_cd'].text if room.elements['room_cd']
        work_renters_room.building_cd = room.elements['building_cd'].text if room.elements['building_cd']
        work_renters_room.clientcorp_room_cd = room.elements['clientcorp/room_cd'].text if room.elements['clientcorp/room_cd']
        work_renters_room.clientcorp_building_cd = room.elements['clientcorp/building_cd'].text if room.elements['clientcorp/building_cd']
        work_renters_room.store_code = room.elements['store/code'].text if room.elements['store/code']
        work_renters_room.store_name = room.elements['store/name'].text if room.elements['store/name']
        work_renters_room.building_name = room.elements['building_name'].text if room.elements['building_name']
        work_renters_room.gaikugoutou = room.elements['gaikugoutou'].text if room.elements['gaikugoutou']
        work_renters_room.room_no = room.elements['room_no'].text if room.elements['room_no']
        work_renters_room.real_building_name = room.elements['real_building_name'].text if room.elements['real_building_name']
        work_renters_room.real_gaikugoutou = room.elements['real_gaikugoutou'].text if room.elements['real_gaikugoutou']
        work_renters_room.real_room_no = room.elements['real_room_no'].text if room.elements['real_room_no']
        work_renters_room.floor = room.elements['floor'].text if room.elements['floor']
        work_renters_room.building_type = room.elements['building_type'].text if room.elements['building_type']
        work_renters_room.structure = room.elements['structure'].text if room.elements['structure']
        work_renters_room.construction = room.elements['construction'].text if room.elements['construction']
        work_renters_room.room_num = room.elements['room_num'].text if room.elements['room_num']
        work_renters_room.address = room.elements['address'].text if room.elements['address']
        work_renters_room.detail_address = room.elements['detail_address'].text if room.elements['detail_address']
        work_renters_room.pref_code = room.elements['pref/code'].text if room.elements['pref/code']
        work_renters_room.pref_name = room.elements['pref/name'].text if room.elements['pref/name']
        work_renters_room.city_code = room.elements['city/code'].text if room.elements['city/code']
        work_renters_room.city_name = room.elements['city/name'].text if room.elements['city/name']
        work_renters_room.choume_code = room.elements['choume/code'].text if room.elements['choume/code']
        work_renters_room.choume_name = room.elements['choume/name'].text if room.elements['choume/name']
        work_renters_room.latitude = room.elements['latitude'].text if room.elements['latitude']
        work_renters_room.longitude = room.elements['longitude'].text if room.elements['longitude']
        work_renters_room.vacant_div = room.elements['vacant_div'].text if room.elements['vacant_div']
        work_renters_room.enter_ym = room.elements['enter_ym'].text if room.elements['enter_ym']
        work_renters_room.new_status = room.elements['new_status'].text if room.elements['new_status']
        work_renters_room.completion_ym = room.elements['completion_ym'].text if room.elements['completion_ym']
        work_renters_room.square = room.elements['square'].text if room.elements['square']
        work_renters_room.room_layout_type = room.elements['room_layout_type'].text if room.elements['room_layout_type']
#        work_renters_room.        #renters_room.work_renters_room_layout_id = room.elements['#renters_room.work_renters_room_layout_id'].text if room.elements['#renters_room.layout_id']
#        work_renters_room.        #renters_room.work_renters_access_id = room.elements['#renters_room.work_renters_access_id'].text if room.elements['#renters_room.work_renters_access_id']
        work_renters_room.cond = room.elements['cond'].text if room.elements['cond']
        work_renters_room.contract_div = room.elements['contract_div'].text if room.elements['contract_div']
        work_renters_room.contract_comment = room.elements['contract_comment'].text if room.elements['contract_comment']
        work_renters_room.rent_amount = room.elements['rent_amount'].text if room.elements['rent_amount']
        work_renters_room.managing_fee = room.elements['managing_fee'].text if room.elements['managing_fee']
        work_renters_room.reikin = room.elements['reikin'].text if room.elements['reikin']
        work_renters_room.shikihiki = room.elements['shikihiki'].text if room.elements['shikihiki']
        work_renters_room.shikikin = room.elements['shikikin'].text if room.elements['shikikin']
        work_renters_room.shoukyakukin = room.elements['shoukyakukin'].text if room.elements['shoukyakukin']
        work_renters_room.hoshoukin = room.elements['hoshoukin'].text if room.elements['hoshoukin']
        work_renters_room.renewal_fee = room.elements['renewal_fee'].text if room.elements['renewal_fee']
        work_renters_room.insurance = room.elements['insurance'].text if room.elements['insurance']
        work_renters_room.agent_fee = room.elements['agent_fee'].text if room.elements['agent_fee']
        work_renters_room.other_fee = room.elements['other_fee'].text if room.elements['other_fee']
        work_renters_room.airconditioner = room.elements['airconditioner'].text if room.elements['airconditioner']
        work_renters_room.washer_space = room.elements['washer_space'].text if room.elements['washer_space']
        work_renters_room.burner = room.elements['burner'].text if room.elements['burner']
        work_renters_room.equipment = room.elements['equipment'].text if room.elements['equipment']
        work_renters_room.carpark_status = room.elements['carpark/status'].text if room.elements['carpark/status']
        work_renters_room.carpark_fee = room.elements['carpark/carpark_fee'].text if room.elements['carpark/carpark_fee']
        work_renters_room.carpark_reikin = room.elements['carpark/reikin'].text if room.elements['carpark/reikin']
        work_renters_room.carpark_shikikin = room.elements['carpark/shikikin'].text if room.elements['carpark/shikikin']
        work_renters_room.carpark_distance_to_nearby = room.elements['carpark/distance_to_nearby'].text if room.elements['carpark/distance_to_nearby']
        work_renters_room.carpark_car_num = room.elements['carpark/car_num'].text if room.elements['carpark/car_num']
        work_renters_room.carpark_indoor = room.elements['carpark/indoor'].text if room.elements['carpark/indoor']
        work_renters_room.carpark_shape = room.elements['carpark/shape'].text if room.elements['carpark/shape']
        work_renters_room.carpark_underground = room.elements['carpark/underground'].text if room.elements['carpark/underground']
        work_renters_room.carpark_roof = room.elements['carpark/roof'].text if room.elements['carpark/roof']
        work_renters_room.carpark_shutter = room.elements['carpark/shutter'].text if room.elements['carpark/shutter']
        work_renters_room.notice = room.elements['notice'].text if room.elements['notice']
        work_renters_room.building_main_catch = room.elements['building_main_catch'].text if room.elements['building_main_catch']
        work_renters_room.room_main_catch = room.elements['room_main_catch'].text if room.elements['room_main_catch']
        work_renters_room.recruit_catch = room.elements['recruit_catch'].text if room.elements['recruit_catch']
        work_renters_room.room_updated_at = room.elements['room_updated_at'].text if room.elements['room_updated_at']
#        work_renters_room.        #renters_room.work_renters_picture_id = room.elements['#renters_room.work_renters_picture_id'].text if room.elements['#renters_room.work_renters_picture_id']
        work_renters_room.zumen_url = room.elements['zumen_url'].text if room.elements['zumen_url']
        work_renters_room.location = room.elements['location'].text if room.elements['location']
        work_renters_room.net_use_freecomment = room.elements['net_use_freecomment'].text if room.elements['net_use_freecomment']
        work_renters_room.athome_pro_comment = room.elements['athome_pro_comment'].text if room.elements['athome_pro_comment']
    
        work_renters_room.save!

        # # 画像を登録
        # RentersRoomPicture.where("renters_room_id = ?", renters_room.id ).update_all("delete_flg = ?", true)
        #
        # picture_num = 0
        # room.elements.each_with_index('picture') do |pic, i|
        #   room_picture = RentersRoomPicture.find_or_create_by_renters_room_id_and_idx(renters_room.id, j)
        #   room_picture.renters_room_id = renters_room.id
        #   room_picture.idx = j
        #
        #   room_picture.true_url = pic.elements['true_url'].text
        #   room_picture.large_url = pic.elements['large_url'].text
        #   room_picture.mini_url = pic.elements['mini_url'].text
        #
        #   room_picture.delete_flg = false
        #   room_picture.save!
        #
        #   picture_num = picture_num + 1
        # end
        #
        # # 画像の枚数を保存
        # renters_room.picture_num = picture_num
        # renters_room.save!
        #
        # if renters_room.building_name
        #   p renters_room.building_name + ' ' + picture_num.to_s + "枚登録"
        # end
        #
      end
    end    
    
  end



  
  
  
  # 管理物件からレンターズの登録内容を更新取得します。
  # def update_all
  #
  #   Room.update_all("renters_room_id = null")
  #
  #   @data_update = DataUpdateTime.find_by_code("310")
  #   @data_update.start_datetime = Time.now
  #   @data_update.update_datetime = nil
  #
  #   @data_update.biru_user_id = @biru_user.id
  #   @data_update.save!
  #
  #   Room.joins(:building => :shop).joins(:building => :trusts).each do |room|
  #
  #     # 取得した建物CD, 部屋CD を元にレンターズAPIを呼び出す
  #     url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&clientcorp_building_cd=#{sprintf("%06d", room.building_cd.to_s)}&clientcorp_room_cd=#{sprintf("%03d", room.code.to_s)}")
  #     xml = open(url).read
  #     doc = REXML::Document.new(xml)
  #
  #     ret_status = doc.elements['results/results_returned']
  #     if ret_status && ret_status.text != "0"
  #
  #       # データが取得できた！
  #       room_code = doc.elements['results/room/room_cd'].text
  #
  #       renters_room = RentersRoom.find_or_create_by_room_code(room_code)
  #
  #       renters_room.room_code = room_code
  #       renters_room.building_code = doc.elements['results/room/building_cd'].text
  #       renters_room.clientcorp_room_cd = doc.elements['results/room/clientcorp_room_cd'].text
  #       renters_room.clientcorp_building_cd = doc.elements['results/room/clientcorp_building_cd'].text
  #       renters_room.store_code = doc.elements['results/room/store/code'].text
  #       renters_room.store_name = doc.elements['results/room/store/name'].text
  #       renters_room.building_name = doc.elements['results/room/building_name'].text
  #       renters_room.room_no = doc.elements['results/room/room_no'].text
  #
  #       renters_room.real_building_name = doc.elements['results/room/real_building_name'].text
  #       renters_room.real_room_no = doc.elements['results/room/real_room_no'].text
  #       renters_room.floor = doc.elements['results/room/floor'].text
  #       renters_room.building_type = doc.elements['results/room/building_type'].text
  #       renters_room.structure = doc.elements['results/room/structure'].text
  #
  #       renters_room.construction = doc.elements['results/room/construction'].text
  #       renters_room.room_num = doc.elements['results/room/room_num'].text
  #       renters_room.address = doc.elements['results/room/address'].text
  #       renters_room.detail_address = doc.elements['results/room/detail_address'].text
  #       renters_room.vacant_div = doc.elements['results/room/vacant_div'].text
  #       renters_room.enter_ym = doc.elements['results/room/enter_ym'].text
  #       renters_room.new_status = doc.elements['results/room/new_status'].text
  #       renters_room.completion_ym = doc.elements['results/room/completion_ym'].text
  #       renters_room.square = doc.elements['results/room/square'].text
  #       renters_room.room_layout_type = doc.elements['results/room/room_layout_type'].text
  #
  #       renters_room.picture_top = doc.elements['results/room/picture/large_url'].text
  #       renters_room.zumen = doc.elements['results/room/zumen_url'].text
  #
  #       renters_room.save!
  #
  #       # 部屋マスタに登録したRenters_idを登録
  #       room_data = Room.find(room.id)
  #       room_data.renters_room_id = renters_room.id
  #       room_data.save!
  #
  #
  #       # 画像を登録
  #       RentersRoomPicture.where("renters_room_id = ?", renters_room.id ).update_all("delete_flg = ?", true)
  #
  #       picture_num = 0
  #
  #       doc.elements.each_with_index('results/room/picture') do |pic, i|
  #         room_picture = RentersRoomPicture.find_or_create_by_renters_room_id_and_idx(renters_room.id, i)
  #         room_picture.renters_room_id = renters_room.id
  #         room_picture.idx = i
  #
  #         room_picture.true_url = pic.elements['true_url'].text
  #         room_picture.large_url = pic.elements['large_url'].text
  #         room_picture.mini_url = pic.elements['mini_url'].text
  #
  #         room_picture.delete_flg = false
  #         room_picture.save!
  #
  #
  #         picture_num = picture_num + 1
  #       end
  #
  #       # 画像の枚数を保存
  #       renters_room.picture_num = picture_num
  #       renters_room.save!
  #
  #
  #     end
  #   end
  #
  #   @data_update.update_datetime = Time.now
  #   @data_update.save!
  #
  #   render 'index'
  #
  # end
  
  
  
  def search
    
    @search_building_cd = params[:building_cd]
    
    # レンターズAPIを呼び出し
    url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&clientcorp_building_cd=#{@search_building_cd}")
    xml = open(url).read
    doc = REXML::Document.new(xml)
    
    # 物件名取得
    biru_nm = doc.elements['results/room/real_building_name']
    if biru_nm 
      @building_name = biru_nm.text
    end
    
    image_url = doc.elements['results/room/picture/large_url']
    if image_url 
      @image_url = image_url.text
    end

    @accesses = doc.elements['results/room/access']
    
    # 紐づく写真を取得
  end
  
  
 # before_filter :init_managements
 #
 #  def init_managements
 #
 #    # 建物名・住所
 #    @building_nm = ""
 #    @building_ad = ""
 #
 #    # 営業所指定
 #    @shop_checked = {}
 #    @shop_checked[:tobu01] = false
 #    @shop_checked[:tobu02] = false
 #    @shop_checked[:tobu03] = false
 #    @shop_checked[:tobu04] = false
 #    @shop_checked[:tobu05] = false
 #    @shop_checked[:tobu06] = false
 #    @shop_checked[:tobu07] = false
 #    @shop_checked[:tobu08] = false
 #    @shop_checked[:sai01] = false
 #    @shop_checked[:sai02] = false
 #    @shop_checked[:sai03] = false
 #    @shop_checked[:sai04] = false
 #    @shop_checked[:sai05] = false
 #    @shop_checked[:sai06] = false
 #    @shop_checked[:sai07] = false
 #    @shop_checked[:sai08] = false
 #    @shop_checked[:chiba01] = false
 #    @shop_checked[:chiba02] = false
 #    @shop_checked[:chiba03] = false
 #    @shop_checked[:chiba04] = false
 #
 #    # 物件種別指定
 #    @build_type_checked = {}
 #    @build_type_checked[:apart] = false
 #    @build_type_checked[:man] = false
 #    @build_type_checked[:bman] = false
 #    @build_type_checked[:tenpo] = false
 #    @build_type_checked[:jimusyo] = false
 #    @build_type_checked[:kojo] = false
 #    @build_type_checked[:soko] = false
 #    @build_type_checked[:kodate] = false
 #    @build_type_checked[:terasu] = false
 #    @build_type_checked[:mezo] = false
 #    @build_type_checked[:ten_jyu] = false
 #    @build_type_checked[:soko_jimu] = false
 #    @build_type_checked[:kojo_soko] = false
 #    @build_type_checked[:syakuti] = false
 #
 #    # 管理方式指定
 #    @manage_type_checked = {}
 #    @manage_type_checked[:kanri_i] = false
 #    @manage_type_checked[:kanri_a] = false
 #    @manage_type_checked[:kanri_b] = false
 #    @manage_type_checked[:kanri_c] = false
 #    @manage_type_checked[:kanri_d] = false
 #    @manage_type_checked[:kanri_soumu] = false
 #    @manage_type_checked[:kanri_toku] = false
 #    @manage_type_checked[:kanri_teiki] = false
 #    @manage_type_checked[:kanri_gyoumu] = false
 #    @manage_type_checked[:kanri_gai] = false
 #
 #    # オブジェクトの初期化
 #    @buildings = []
 #    @shops = []
 #    @owners = []
 #    @trusts = []
 #    @owner_to_buildings = []
 #
 #    # 貸主名・住所
 #    @owner_nm = ""
 #    @owner_ad = ""
 #
 #    # 検索種別（建物検索：１　貸主検索：２）
 #    @search_type = 1
 #
 #    # バルク検索用の文字列
 #    @bulk_text = ""
 #
 #  end
 #
 #  # オーナー情報確認用のwindowを表示します。
 #  def popup_owner
 #    @owner = Owner.find(params[:id])
 #    render :layout => 'popup'
 #  end
 #
 #  # オーナー情報の登録をポップアップから行います。
 #  def popup_owner_update
 #    @owner = Owner.find(params[:id])
 #    if @owner.update_attributes(params[:owner])
 #    end
 #
 #    render :action=>'popup_owner', :layout => 'popup'
 #
 #  end
 #
 #  # 建物情報確認用のwindowを表示する。
 #  def popup_building
 #    @building = Building.find(params[:id])
 #    render :layout => 'popup'
 #  end
 #
 #  def popup_building_update
 #    @building = Building.find(params[:id])
 #
 #    if @building.update_attributes(params[:building])
 #    end
 #
 #    render :action=>'popup_building', :layout => 'popup'
 #  end
 #
 #  def index
 #    # 営業所のみ表示
 #    gon.shops = Shop.find(:all)
 #  end
 #
 #  # 貸主検索
 #  def search_owners
 #
 #    @search_type = 2
 #
 #    # 元データを取得
 #    tmp_owners = Owner.joins(:trusts => :building).scoped
 #
 #    # 貸主名の絞り込み
 #    word = params[:owner_name]
 #    if word.length > 0
 #      tmp_owners = tmp_owners.where("owners.name like ?", "%#{word}%")
 #      @owner_nm = word
 #    end
 #
 #    # 住所の絞り込み
 #    address = params[:owner_address]
 #    if address.length > 0
 #      tmp_owners = tmp_owners.where("owners.address like ?", "%#{address}%")
 #      @owner_ad = address
 #    end
 #
 #    # 絞り込んだ貸主から、建物の配列を取得する
 #    @buildings = []
 #    tmp_owners.group("buildings.id").select("buildings.id").each do |id|
 #      @buildings << Building.find_by_id(id)
 #    end
 #
 #    if @buildings
 #      buildings_to_gon(@buildings)
 #    end
 #
 #    render 'index'
 #
 #
 #  end
 #
 #  # 物件検索
 #  def search_buildings
 #
 #    @search_type = 1
 #
 #    # 委託契約がされてないものも削除フラグが立っていない建物ならば出力する。
 #    tmp_buildings = Building.scoped
 #    tmp_buildings = tmp_buildings.includes(:build_type)
 #    tmp_buildings = tmp_buildings.includes(:trusts)
 #    tmp_buildings = tmp_buildings.includes(:trusts => :owner)
 #    tmp_buildings = tmp_buildings.includes(:shop)
 #
 #
 #    # 建物名の絞り込み
 #    word = params[:biru_name]
 #    if word.length > 0
 #      tmp_buildings = tmp_buildings.where("name like ?", "%#{word}%" )
 #      @building_nm = word
 #    end
 #
 #    address = params[:biru_address]
 #    if address.length > 0
 #      tmp_buildings = tmp_buildings.where("address like ?", "%#{address}%" )
 #      @building_ad = address
 #    end
 #
 #    # 営業所チェックボックスが選択されていたら、それを絞り込む
 #    if params[:shop]
 #
 #      shop_arr = []
 #      params[:shop].keys.each do |key|
 #        shop_arr.push(Shop.find_by_code(params[:shop][key]).id)
 #        @shop_checked[key.to_sym] = true
 #      end
 #      tmp_buildings = tmp_buildings.where(:shop_id=>shop_arr)
 #    end
 #
 #    # 物件種別で絞り込み
 #    if params[:build_type]
 #      build_type = []
 #      params[:build_type].keys.each do |key|
 #        build_type.push(BuildType.find_by_code(params[:build_type][key]).id)
 #        @build_type_checked[key.to_sym] = true
 #      end
 #      tmp_buildings = tmp_buildings.where(:build_type_id=>build_type)
 #    end
 #
 #
 #    # 管理方式で絞り込み
 #    if params[:manage_type]
 #      manage_type = []
 #      params[:manage_type].keys.each do |key|
 #        manage_type.push(ManageType.find_by_code(params[:manage_type][key]).id)
 #        @manage_type_checked[key.to_sym] = true
 #      end
 #
 #      # ここでInner Joinをして管理方式が存在するもののみを絞り込む
 #      tmp_buildings = tmp_buildings.where("trusts.manage_type_id"=>manage_type)
 #    end
 #
 #    # 物件情報を出力
 #    if tmp_buildings
 #      buildings_to_gon(tmp_buildings)
 #    end
 #
 #    render 'index'
 #
 #  end
 #
 #  # 指定した建物情報を元に、出力用のjavascriptオブジェクトを作成します。
 #  def buildings_to_gon(buildings)
 #
 #      if buildings.size == 0
 #        # 表示する建物が存在しない時
 #        @owners = []
 #        @trusts = []
 #        @owner_to_buildings = []
 #        @building_to_owners = []
 #
 #        @shops =  Shop.find(:all)
 #
 #      else
 #
 #        # 建物にマーカーを設定
 #        set_biru_obj(buildings)
 #        @buildings = buildings
 #
 #        # 建物に紐づく貸主／委託契約を取得(合わせて管理方式の絞り込み)
 #        @shops, @owners, @trusts, @owner_to_buildings, @building_to_owners = get_building_info(buildings)
 #
 #      end
 #
 #      gon.buildings = @buildings
 #      gon.owners = @owners # 関連する貸主
 #      gon.trusts = @trusts # 関連する委託契約
 #      gon.shops = @shops    # 関連する営業所
 #      gon.owner_to_buildings = @owner_to_buildings # 建物と貸主をひもづける情報
 #      gon.building_to_owners = @building_to_owners
 #
 #  end
 #
 #  # 指定された建物に紐づく営業所・貸主・委託情報を取得する
 #  def get_building_info(buildings)
 #
 #    shops = []
 #    owners = []
 #    trusts = []
 #    owner_to_buildings = []
 #    building_to_owners = []
 #
 #    buildings.each do |biru|
 #
 #      shops << biru.shop if biru.shop
 #
 #      biru.trusts.each do |trust|
 #
 #        trusts << trust
 #
 #        # 貸主登録
 #        if trust.owner
 #          tmp_owner = trust.owner
 #          owners << tmp_owner
 #
 #          # 貸主に紐づく建物一覧を作成する。
 #          owner_to_buildings[tmp_owner.id] = [] unless owner_to_buildings[tmp_owner.id]
 #          owner_to_buildings[tmp_owner.id] << biru
 #
 #          # 建物に紐づく貸主一覧を作成する。※本来建物に対するオーナーは１人だが、念のため複数オーナーも対応する。
 #          building_to_owners[biru.id] = [] unless building_to_owners[biru.id]
 #          building_to_owners[biru.id] << tmp_owner
 #
 #        end
 #      end
 #
 #    end
 #
 #    owners.uniq! if owners
 #    trusts.uniq! if trusts
 #    shops.uniq! if shops
 #
 #    return shops, owners, trusts, owner_to_buildings, building_to_owners
 #
 #  end
 #
 #  # 建物インスタンスに物件種別・管理方式を設定する。
 #  def set_biru_obj(buildings)
 #    buildings.each do |biru|
 #      if biru.build_type
 #        biru.tmp_build_type_icon = biru.build_type.icon
 #      else
 #        biru.tmp_build_type_icon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%e4%b8%8d|00FF00|000000'
 #      end
 #
 #      biru.trusts.each do |trust|
 #        if trust.manage_type
 #          biru.tmp_manage_type_icon = trust.manage_type.icon
 #        end
 #
 #      end
 #
 #    end
 #
 #  end
 #
 #  #########################
 #  # ファイル一括検索を行います。
 #  #########################
 #  def bulk_search_text
 #    @search_type = 1 # 建物を初期表示
 #    @bulk_text = params[:bulk_search_text]
 #    buildings_to_gon(parse_buildings(@bulk_text))
 #    render 'index'
 #  end
 #
 #  def bulk_search_file
 #    @search_type = 1 # 建物を初期表示
 #    buildings_to_gon(parse_buildings(params[:file].read))
 #    render 'index'
 #  end
 #
 #  # 文字列から建物情報を作成する
 #  def parse_buildings(str)
 #    buildings = []
 #    codes = []
 #
 #    # 改行・タブ・「、」は全て「,」にする。
 #    str.gsub("、",",").gsub(/(\r\n|\r|\n)/, ",").gsub(/\t/,",").split(",").each do |code|
 #      if code.length > 0
 #        codes << code
 #      end
 #    end
 #
 #    if codes.length > 0
 #      buildings = Building.where(:code=>codes)
 #    end
 #
 #    return buildings
 #
 #  end
end
