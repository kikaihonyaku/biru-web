#-*- encoding:utf-8 -*-
require 'open-uri' # open関数でurlを読み込む為に必要
require 'rexml/document'

class RentersController < ApplicationController
  
  respond_to :html, :json
  
  def index
    @data_update = DataUpdateTime.find_by_code("310")
    @batch_list = WorkRentersRoom.group(:batch_cd).select(:batch_cd).order("batch_cd desc")
    

    # 営業所
    # レンターズ掲載戸数
    # SUMOハイライト数
    # リンク
    
    grid_data = {}
    ActiveRecord::Base.connection.select_all(get_renters_sql(false, "")).each do |rec|
      
      # 初めての営業所の時、初期化

      unless grid_data[rec['store_code']]
        grid_data[rec['store_code']] = {:store_name => rec['store_name'], :summary => 0 ,:suumo_highlite => 0, :url => 'map' }
      end

      rec_data = grid_data[rec['store_code']]
      rec_data[:summary] = rec_data[:summary] + 1

      # SUMO残数を取得
      madori = 1 - rec['madori'].to_i
      madori = 0  if madori < 0

      gaikan = 2 - rec['gaikan'].to_i
      gaikan = 0 if gaikan < 0

      naikan = 9 - rec['naikan'].to_i
      naikan = 0 if naikan < 0

      gaikan_etc = 2 - rec['gaikan_etc'].to_i
      gaikan_etc = 0 if gaikan_etc < 0

      syuuhen = 6 - rec['syuuhen'].to_i
      syuuhen = 0 if syuuhen < 0
          
      # 全合計が０ならば、ハイライト対象 
      if ( madori + gaikan + naikan + gaikan_etc + syuuhen) == 0
        rec_data[:suumo_highlite] = rec_data[:suumo_highlite] + 1
      end
      
    end
    
    
    
    
    # ハッシュを配列に変換
    # data_list = []
    # grid_data.keys.each do |store_code|
    #
    #   arr = grid_data[store_code]
    #   arr['store_code'] = store_code
    #   data_list.push(arr)
    # end
    
    data_list = []
    data_list.push({:store_code =>'335', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=335', :group_name=>'01東武', :store_name =>'草加' }) #草加
    data_list.push({:store_code =>'336', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=336', :group_name=>'01東武', :store_name =>'草加新田' }) #草加新田
    data_list.push({:store_code =>'339', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=339', :group_name=>'01東武', :store_name =>'北千住' }) #北千住
    data_list.push({:store_code =>'334', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=334', :group_name=>'01東武', :store_name =>'南越谷' }) #南越谷本店
    data_list.push({:store_code =>'340', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=340', :group_name=>'01東武', :store_name =>'越谷' }) #越谷
    data_list.push({:store_code =>'337', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=337', :group_name=>'01東武', :store_name =>'北越谷' }) #北越谷
    data_list.push({:store_code =>'338', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=338', :group_name=>'01東武', :store_name =>'春日部' }) #春日部
    data_list.push({:store_code =>'667', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=667', :group_name=>'01東武', :store_name =>'せんげん台' }) #せんげん台
    data_list.push({:store_code =>'2763', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=2763', :group_name=>'02さいたま', :store_name =>'戸田公園' }) #戸田公園
    data_list.push({:store_code =>'341', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=341', :group_name=>'02さいたま', :store_name =>'戸田' }) #戸田
    data_list.push({:store_code =>'342', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=342', :group_name=>'02さいたま', :store_name =>'武蔵浦和' }) #武蔵浦和
    data_list.push({:store_code =>'344', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=344', :group_name=>'02さいたま', :store_name =>'与野' }) #与野
    data_list.push({:store_code =>'348', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=348', :group_name=>'02さいたま', :store_name =>'浦和' }) #浦和
    data_list.push({:store_code =>'346', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=346', :group_name=>'02さいたま', :store_name =>'川口' }) #川口
    data_list.push({:store_code =>'349', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=349', :group_name=>'02さいたま', :store_name =>'東浦和' }) #東浦和
    data_list.push({:store_code =>'343', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=343', :group_name=>'02さいたま', :store_name =>'東川口' }) #東川口
    data_list.push({:store_code =>'345', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=345', :group_name=>'02さいたま', :store_name =>'戸塚安行' }) #戸塚安行
    data_list.push({:store_code =>'352', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=352', :group_name=>'03千葉', :store_name =>'松戸' }) #松戸
    data_list.push({:store_code =>'347', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=347', :group_name=>'03千葉', :store_name =>'北松戸' }) #北松戸
    data_list.push({:store_code =>'351', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=351', :group_name=>'03千葉', :store_name =>'南流山' }) #南流山
    data_list.push({:store_code =>'350', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=350', :group_name=>'03千葉', :store_name =>'柏' }) #柏
    data_list.push({:store_code =>'3', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=335,336,339,334,340,337,338,667', :group_name=>'00支店', :store_name =>'東武支店' }) #東武
    data_list.push({:store_code =>'4', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=2763,341,342,344,348,346,349,343,345', :group_name=>'00支店', :store_name =>'さいたま支店' }) #さいたま
    data_list.push({:store_code =>'5', :summary => 0 ,:suumo_highlite => 0, :url => 'map?stcd=352,347,351,350', :group_name=>'00支店', :store_name =>'千葉支店' }) #千葉

    
    toubu_value = 0
    toubu_suumo = 0
    
    saitama_value = 0
    saitama_suumo = 0
    
    chiba_value = 0
    chiba_suumo = 0
    
    data_list.each do |data_hash|
      
      if data_hash[:group_name] == '00支店'
        # 支店データを設定
        if data_hash[:store_name] == '東武支店'
           data_hash[:summary] = toubu_value
           data_hash[:suumo_highlite] = toubu_suumo
           
        elsif data_hash[:store_name] == 'さいたま支店'
          data_hash[:summary] = saitama_value
          data_hash[:suumo_highlite] = saitama_suumo
          
        elsif data_hash[:store_name] == '千葉支店'
          data_hash[:summary] = chiba_value
          data_hash[:suumo_highlite] = chiba_suumo
          
        end
        
      else
        
        # 営業所のデータを取得
        grid_rec = grid_data[data_hash[:store_code]]
        if grid_rec
          data_hash[:summary] = grid_rec[:summary]
          data_hash[:suumo_highlite] = grid_rec[:suumo_highlite]
          
          
          if data_hash[:group_name] == '01東武'
            toubu_value = toubu_value + grid_rec[:summary]
            toubu_suumo = toubu_suumo + grid_rec[:suumo_highlite]
            
          elsif data_hash[:group_name] == '02さいたま'
            saitama_value = saitama_value + grid_rec[:summary]
            saitama_suumo = saitama_suumo + grid_rec[:suumo_highlite]

          elsif data_hash[:group_name] == '03千葉'
            chiba_value = chiba_value + grid_rec[:summary]
            chiba_suumo = chiba_suumo + grid_rec[:suumo_highlite]

          end
          
          
        end
        
      end
      
    end
      
    gon.data_list = data_list
    
  end
  
  
  
  def map
    
    # 営業所
    # 物件名
    # 住所
    # 間取り
    # 外装
    # 内装
    # SUMOハイライト数
    # リンク
    
    # building_code順でレンターズデータを取得
    buildings = []
    rooms = {}
    grid_renters_data = []
    tmp_building_code = ""
    
    shop_where = ""
    if params[:stcd]
      params[:stcd].split(",").each do |store_code|
        # 数字になり得るのなら引数として採用
        if store_code.strip =~ /\A-?\d+(.\d+)?\Z/
          
          unless shop_where.length == 0
            shop_where = shop_where + ","
          end
        
          shop_where = shop_where + store_code
          
        end
        
      end
    end
    
    ActiveRecord::Base.connection.select_all(get_renters_sql(true, shop_where)).each do |rec|
      
      # gridに表示するデータを取得
      grid_renters_data.push(rec)
      
      # google mapに表示するデータを取得
      unless tmp_building_code == rec['building_id']
        
        # 地図にマッピングする物件を取得
        building = {}
        building[:id] = rec['building_id']
        building[:name] = rec['real_building_name']
        building[:address] = rec['address']
        building[:latitude] = rec['latitude']
        building[:longitude] = rec['longitude']
        buildings.push(building)
        
        rooms[rec['building_id']] = []
        tmp_building_code = rec['building_id']
        
      end
      
      room = {}
      room['room_code'] = rec['room_code']
      room['room_no'] = rec['real_room_no']

      room['madori'] = rec['madori']
      room['gaikan'] = rec['gaikan']
      room['naikan'] = rec['naikan']
      room['gaikan_etc'] = rec['gaikan_etc']
      room['syuuhen'] = rec['syuuhen']
      # room['all_sum'] = rec['all_sum']

      

      rooms[rec['building_id']].push(room)
      
    end
    
    gon.buildings = buildings
    gon.grid_renters_data = grid_renters_data
    gon.rooms = rooms
    
  end
  
  # order : 並べ替えの指定
  def get_renters_sql(order, store_list)
    strSql = "
    select
    renters_room_id
    ,store_code
    ,store_name
    ,room_code 
    ,real_building_name
    ,real_room_no
    ,building_code
    ,building_id
    ,address
    ,latitude
    ,longitude
    ,J00 as madori
    ,T00 as gaikan
    ,J01 + J02 + J03 + J04 + J05 + J06 + J08 + J09 as naikan
    ,T03 + T04 + T05 + T06 + T08 + T11 as gaikan_etc
    ,T01 as syuuhen
    ,J00 + J00 + J01 + J02 + J03 + J04 + J05 + J06 + J07 + J08 + J09 + T00 + T01 + T02 + T03 + T04 + T05 + T06 + T07 + T08 + T09 + T10 + T11 as all_sum 
    from (
    select 
    a.id as renters_room_id
    ,a.store_code
    ,a.store_name
    ,a.room_code 
    ,a.real_building_name
    ,a.real_room_no
    ,a.building_code
    ,c.id as building_id
    ,c.address
    ,c.latitude
    ,c.longitude
    ,COUNT(CASE WHEN b.sub_category_code = 'J00' THEN 1 ELSE NULL END ) AS J00
    ,COUNT(CASE WHEN b.sub_category_code = 'J01' THEN 1 ELSE NULL END ) AS J01
    ,COUNT(CASE WHEN b.sub_category_code = 'J02' THEN 1 ELSE NULL END ) AS J02
    ,COUNT(CASE WHEN b.sub_category_code = 'J03' THEN 1 ELSE NULL END ) AS J03
    ,COUNT(CASE WHEN b.sub_category_code = 'J04' THEN 1 ELSE NULL END ) AS J04
    ,COUNT(CASE WHEN b.sub_category_code = 'J05' THEN 1 ELSE NULL END ) AS J05
    ,COUNT(CASE WHEN b.sub_category_code = 'J06' THEN 1 ELSE NULL END ) AS J06
    ,COUNT(CASE WHEN b.sub_category_code = 'J07' THEN 1 ELSE NULL END ) AS J07
    ,COUNT(CASE WHEN b.sub_category_code = 'J08' THEN 1 ELSE NULL END ) AS J08
    ,COUNT(CASE WHEN b.sub_category_code = 'J09' THEN 1 ELSE NULL END ) AS J09
    ,COUNT(CASE WHEN b.sub_category_code = 'T00' THEN 1 ELSE NULL END ) AS T00
    ,COUNT(CASE WHEN b.sub_category_code = 'T01' THEN 1 ELSE NULL END ) AS T01
    ,COUNT(CASE WHEN b.sub_category_code = 'T02' THEN 1 ELSE NULL END ) AS T02
    ,COUNT(CASE WHEN b.sub_category_code = 'T03' THEN 1 ELSE NULL END ) AS T03
    ,COUNT(CASE WHEN b.sub_category_code = 'T04' THEN 1 ELSE NULL END ) AS T04
    ,COUNT(CASE WHEN b.sub_category_code = 'T05' THEN 1 ELSE NULL END ) AS T05
    ,COUNT(CASE WHEN b.sub_category_code = 'T06' THEN 1 ELSE NULL END ) AS T06
    ,COUNT(CASE WHEN b.sub_category_code = 'T07' THEN 1 ELSE NULL END ) AS T07
    ,COUNT(CASE WHEN b.sub_category_code = 'T08' THEN 1 ELSE NULL END ) AS T08
    ,COUNT(CASE WHEN b.sub_category_code = 'T09' THEN 1 ELSE NULL END ) AS T09
    ,COUNT(CASE WHEN b.sub_category_code = 'T10' THEN 1 ELSE NULL END ) AS T10
    ,COUNT(CASE WHEN b.sub_category_code = 'T11' THEN 1 ELSE NULL END ) AS T11
    from renters_rooms a 
    inner join renters_room_pictures b on a.id = b.renters_room_id 
    inner join renters_buildings c on a.renters_building_id = c.id 
    "
    
    
    if store_list.length > 0
      strSql = strSql + " where store_code IN (" + store_list + ") "
    end
    
    strSql = strSql + "
    group by a.id
    ,a.store_code
    ,a.store_name
    ,a.room_code 
    ,a.real_building_name
    ,a.real_room_no
    ,a.building_code
    ,c.id
    ,c.address
    ,c.latitude
    ,c.longitude
    )
    "
    
    if order
      strSql = strSql + " order by building_code"
    end
    
    strSql
    
  end
  
  
  def get_all_building
    biru = nil
    RentersRoom.order("building_code").each do |room|
    	
    	unless biru
        # biruが登録されていない時は建物を登録する
        biru = room.renters_building
        @buildings << biru
        
      else
      	# biruが登録されているが、建物コードが異なる時
      	unless biru.building_cd == room.renters_building.building_cd
      		
	        biru = room.renters_building
	        @buildings << biru
      		
      	else
      		# すでに登録済みの建物の時はなにもしない
      	end
    	end
    	
      @rooms[biru.id] = [] unless @rooms[biru.id]
      @rooms[biru.id] << room
    end

  end
  
  
  
  # 画像一覧を表示します
  def pictures
    @room = Room.find(params[:id])
    @room_renters = RentersRoom.find(@room.renters_room_id)
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
  
  
  
  # 管理物件からレンターズの登録内容を更新取得します。
   def update_all

     @data_update = DataUpdateTime.find_by_code("310")
     @data_update.start_datetime = Time.now
     @data_update.update_datetime = nil
     @data_update.biru_user_id = @biru_user.id
     @data_update.save!

 		# レンターズのデータを本番に反映する
     renters_reflect(params[:batch][:value])
  
     @data_update.update_datetime = Time.now
     @data_update.save!
    
     redirect_to :action=>'index'
    
   end
  
   # レンターズデータを本番に反映する
   # レンターズデータを本番に反映する
   def renters_reflect(batch_cd)
    
     RentersBuilding.update_all("delete_flg = ?", true) # SQLServerは1
     RentersRoom.update_all("delete_flg = ?", true) # SQLServerは1
     RentersRoomPicture.update_all("delete_flg = ?", true) # SQLServerは1
    
     chk_building_code = ""
    
     building = nil
     # renters_roomへの反映
     WorkRentersRoom.where("batch_cd = ?", batch_cd).order("building_cd").each do |work_room|
      
       # もし建物コードが変わったら最新の建物コードを取得
       unless chk_building_code == work_room.building_cd
      	
 	      building = RentersBuilding.unscoped.find_or_create_by_building_cd(work_room.building_cd)
 	      building.building_cd = work_room.building_cd
 	      building.clientcorp_building_cd = work_room.clientcorp_building_cd

 	      #building.store_code = work_room.store_code
 	      #building.store_name = work_room.store_name
 	      building.building_name = work_room.building_name
 	      building.real_building_name = work_room.real_building_name
 	      building.building_type = work_room.building_type
 	      building.structure = work_room.structure
 	      building.address = work_room.detail_address

         unless building.gmaps
   	      # geocode
   	      gmaps_ret = Gmaps4rails.geocode(building.address)
   	      building.latitude = gmaps_ret[0][:lat]
   	      building.longitude = gmaps_ret[0][:lng]
   	      building.gmaps = true
         end

 	      building.delete_flg = false
 	      building.save!
	      
       	# 建物コードの保存
       	chk_building_code =  work_room.building_cd
      	
       end
      
       room = RentersRoom.unscoped.find_or_create_by_room_code(work_room.room_cd)
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
       room.renters_building_id = building.id
       room.save!
      
       # 部屋の物件情報を反映
       WorkRentersRoomPicture.where("batch_cd = ?", batch_cd).where("batch_cd_idx = ?", work_room.batch_cd_idx).order("batch_picture_idx").each_with_index do |work_picture, j |
       	picture = RentersRoomPicture.unscoped.find_or_create_by_renters_room_id_and_idx(room.id, j)
 				picture.renters_room_id = room.id
 				picture.idx = j
 				picture.true_url = work_picture.true_url
 				picture.large_url = work_picture.large_url
 				picture.mini_url = work_picture.mini_url
 				picture.main_category_code = work_picture.main_category_code
 				picture.sub_category_code = work_picture.sub_category_code
 				picture.sub_category_name = work_picture.sub_category_name
 				picture.caption = work_picture.caption
 				picture.priority = work_picture.priority
 				picture.entry_datetime = work_picture.entry_datetime
 				picture.delete_flg = false
 				picture.save!
       end
     end
    
   end
  
  
  
end
