#-*- encoding:utf-8 -*-
require 'open-uri' # open関数でurlを読み込む為に必要
require 'rexml/document'

class RentersController < ApplicationController
  
  def index
    
    
  end
  
  # 画像一覧を表示します
  def pictures
    @room = Room.find(params[:id])
    @room_renters = RentersRoom.find(@room.renters_room_id)
    
  end
  
  
  # 管理物件からレンターズの登録内容を更新取得します。
  def update_all
    
    Room.update_all("renters_room_id = null")
    
    Room.joins(:building => :shop).joins(:building => :trusts).each do |room|
            
      # 取得した建物CD, 部屋CD を元にレンターズAPIを呼び出す
      url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&clientcorp_building_cd=#{sprintf("%06d", room.building_cd.to_s)}&clientcorp_room_cd=#{sprintf("%03d", room.code.to_s)}")
      xml = open(url).read
      doc = REXML::Document.new(xml)
      
      ret_status = doc.elements['results/results_returned']
      if ret_status && ret_status.text != "0"
        
        # データが取得できた！
        room_code = doc.elements['results/room/room_cd'].text
        
        renters_room = RentersRoom.find_or_create_by_room_code(room_code)
        
        renters_room.room_code = room_code
        renters_room.building_code = doc.elements['results/room/building_cd'].text
        renters_room.clientcorp_room_cd = doc.elements['results/room/clientcorp_room_cd'].text
        renters_room.clientcorp_building_cd = doc.elements['results/room/clientcorp_building_cd'].text
        renters_room.store_code = doc.elements['results/room/store/code'].text
        renters_room.store_name = doc.elements['results/room/store/name'].text
        renters_room.building_name = doc.elements['results/room/building_name'].text
        renters_room.room_no = doc.elements['results/room/room_no'].text
        
        renters_room.real_building_name = doc.elements['results/room/real_building_name'].text
        renters_room.real_room_no = doc.elements['results/room/real_room_no'].text
        renters_room.floor = doc.elements['results/room/floor'].text
        renters_room.building_type = doc.elements['results/room/building_type'].text
        renters_room.structure = doc.elements['results/room/structure'].text


        renters_room.construction = doc.elements['results/room/construction'].text
        renters_room.room_num = doc.elements['results/room/room_num'].text
        renters_room.address = doc.elements['results/room/address'].text
        renters_room.detail_address = doc.elements['results/room/detail_address'].text
        renters_room.vacant_div = doc.elements['results/room/vacant_div'].text
        renters_room.enter_ym = doc.elements['results/room/enter_ym'].text
        renters_room.new_status = doc.elements['results/room/new_status'].text
        renters_room.completion_ym = doc.elements['results/room/completion_ym'].text
        renters_room.square = doc.elements['results/room/square'].text
        renters_room.room_layout_type = doc.elements['results/room/room_layout_type'].text
        
        renters_room.picture_top = doc.elements['results/room/picture/large_url'].text
        renters_room.zumen = doc.elements['results/room/zumen_url'].text


        
        renters_room.save!
        
        # 部屋マスタに登録したRenters_idを登録
        room_data = Room.find(room.id)
        room_data.renters_room_id = renters_room.id
        room_data.save!
        
        
        # 画像を登録
        RentersRoomPicture.where("renters_room_id = ?", renters_room.id ).update_all("delete_flg = ?", true)
        
        picture_num = 0
        
        doc.elements.each_with_index('results/room/picture') do |pic, i|
          room_picture = RentersRoomPicture.find_or_create_by_renters_room_id_and_idx(renters_room.id, i)
          room_picture.renters_room_id = renters_room.id
          room_picture.idx = i
          
          room_picture.true_url = pic.elements['true_url'].text
          room_picture.large_url = pic.elements['large_url'].text
          room_picture.mini_url = pic.elements['mini_url'].text
          
          room_picture.delete_flg = false
          room_picture.save!
          
          
          picture_num = picture_num + 1
        end
        
        # 画像の枚数を保存
        renters_room.picture_num = picture_num
        renters_room.save!
        
        
      end
    end
    
  end
  
  
  
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
