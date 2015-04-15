# -*- coding:utf-8 -*-

require 'csv'
require 'kconv'
require 'date'
#require "moji"
require 'digest/md5'

require 'open-uri' # open関数でurlを読み込む為に必要
require 'rexml/document'


namespace :biruweb do
	
	task :renters_update_test => :environment  do
		
	    batch_cd = Time.now.strftime('%Y%m%d%H%M%S')
	    
	    @data_update = DataUpdateTime.find_by_code("310")
	    @data_update.start_datetime = Time.now
	    @data_update.update_datetime = nil
	    @data_update.biru_user_id = 1
	    @data_update.save!

			# レンターズデータを取得
	    #renters_work_data(batch_cd)
	    
	    # レンターズデータを反映
	    #renters_reflect(batch_cd)
	    renters_reflect("20141113010010")

	    @data_update.update_datetime = Time.now
	    @data_update.save!
	    
	    P "開始:" + @data_update.start_datetime.to_s + " 終了:" + @data_update.update_datetime.to_s
	end
		  
	
	task :renters_update => :environment  do
		
	    batch_cd = Time.now.strftime('%Y%m%d%H%M%S')
	    
	    @data_update = DataUpdateTime.find_by_code("310")
	    @data_update.start_datetime = Time.now
	    @data_update.update_datetime = nil
	    @data_update.biru_user_id = 1
	    @data_update.save!

			# レンターズデータを取得
	    renters_work_data(batch_cd)
	    
	    # レンターズデータを反映
	    renters_reflect(batch_cd)

	    @data_update.update_datetime = Time.now
	    @data_update.save!
	    
	    p "開始:" + @data_update.start_datetime.to_s + " 終了:" + @data_update.update_datetime.to_s
	end
		  
	# ワークデータを作成します
	def renters_work_data(batch_cd)
		
	  get_cnt = 50
	  start_idx = 1
	  
	  # 不要データを削除
	  WorkRentersRoom.destroy_all
	  WorkRentersRoomPicture.destroy_all
	  
	  loop do
	    
	    # url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&count=#{get_cnt.to_s}&start=#{start_idx.to_s}&vacant_div=3,4&torihiki_mode=1,2,3,4")
	    url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&count=#{get_cnt.to_s}&start=#{start_idx.to_s}&vacant_div=3,4")
	    xml = open(url).read
	    doc = REXML::Document.new(xml)
	    
	    # １件も取得できなかったら終了
	    ret_status = doc.elements['results/results_returned']
	    break unless ret_status
	    break if ret_status.text == "0"

	    # 次の取得の準備
	    start_idx = start_idx + get_cnt
	    
	    #break if start_idx > 100
	    
	    # 配列がなくなるまで建物・部屋を作成
	    doc.elements.each_with_index('results/room') do |room, i|
	      p room.elements['room_cd'].text
	      
	      # レンターズ 部屋情報の取得
	      work_renters_room = WorkRentersRoom.create
	      work_renters_room.batch_cd = batch_cd
	      work_renters_room.batch_cd_idx = start_idx + i
	      work_renters_room.room_cd = room.elements['room_cd'].text if room.elements['room_cd']
	      work_renters_room.building_cd = room.elements['building_cd'].text if room.elements['building_cd']
	      work_renters_room.clientcorp_room_cd = room.elements['clientcorp_room_cd'].text if room.elements['clientcorp_room_cd']
	      work_renters_room.clientcorp_building_cd = room.elements['clientcorp_building_cd'].text if room.elements['clientcorp_building_cd']
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
	  
        work_renters_room.notice_a = room.elements['notice[1]'].text if room.elements['notice[1]']
        work_renters_room.notice_b = room.elements['notice[2]'].text if room.elements['notice[2]']
        work_renters_room.notice_c = room.elements['notice[3]'].text if room.elements['notice[3]']
        work_renters_room.notice_d = room.elements['notice[4]'].text if room.elements['notice[4]']
        work_renters_room.notice_e = room.elements['notice[5]'].text if room.elements['notice[5]']
        work_renters_room.notice_f = room.elements['notice[6]'].text if room.elements['notice[6]']
        work_renters_room.notice_g = room.elements['notice[7]'].text if room.elements['notice[7]']
        work_renters_room.notice_h = room.elements['notice[8]'].text if room.elements['notice[8]']
		work_renters_room.torihiki_mode = room.elements['torihiki_mode'].text if room.elements['torihiki_mode']

	      work_renters_room.save!
	      
	      # 画像を登録
	      picture_num = 0
	      room.elements.each_with_index('picture') do |pic, j|
	      	
	        work_picture = WorkRentersRoomPicture.create
	        work_picture.batch_cd = work_renters_room.batch_cd
	        work_picture.batch_cd_idx = work_renters_room.batch_cd_idx
	        work_picture.batch_picture_idx = j + 1
	        work_picture.room_cd = work_renters_room.room_cd
	        
					work_picture.true_url = pic.elements['true_url'].text
					work_picture.large_url = pic.elements['large_url'].text
					work_picture.mini_url = pic.elements['mini_url'].text
					work_picture.main_category_code = pic.elements['main_category/code'].text
					work_picture.sub_category_code = pic.elements['sub_category/code'].text
					work_picture.sub_category_name = pic.elements['sub_category/name'].text
					
					work_picture.caption = pic.elements['caption'].text
					work_picture.priority = pic.elements['priority'].text
					work_picture.entry_datetime = pic.elements['entry_datetime'].text
					
					work_picture.save!

					picture_num = picture_num + 1
					
	      end
	      
	      # 画像の枚数を保存
	      #work_renters_room.picture_num = picture_num
	      #work_renters_room.save!
	      
	      if work_renters_room.building_name
	        p work_renters_room.building_name + ' ' + picture_num.to_s + "枚登録"
	      end
	    end
	  end
	end


	# レンターズデータを本番に反映する
	def renters_reflect(batch_cd)
	  
	  RentersBuilding.update_all("delete_flg = 1") # SQLServerは1
	  RentersRoom.update_all("delete_flg = 1") # SQLServerは1
	  RentersRoomPicture.update_all("delete_flg = 1") # SQLServerは1
	  
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
	    
      room.notice_a =  work_room.notice_a
      room.notice_b = work_room.notice_b
      room.notice_c = work_room.notice_c
      room.notice_d = work_room.notice_d
      room.notice_e = work_room.notice_e
      room.notice_f = work_room.notice_f
      room.torihiki_mode = work_room.torihiki_mode
      if room.torihiki_mode == '仲介'
        room.torihiki_mode_sakimono = true
      else
        room.torihiki_mode_sakimono = false
      end
	    
      room.notice_g = work_room.notice_g
      room.notice_h = work_room.notice_h

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

	###########################
	# レンターズデータ取得
	###########################
	# create_work_renters_rooms


end
