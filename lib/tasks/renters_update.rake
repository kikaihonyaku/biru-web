# -*- coding:utf-8 -*-

require 'csv'
require 'kconv'
require 'date'
#require "moji"
require 'digest/md5'

require 'open-uri' # open関数でurlを読み込む為に必要
require 'rexml/document'


namespace :biruweb do
	
	task :renters_update => :environment  do
		
		begin
			
		  # 不要データを削除(ワークファイルの削除は、途中で処理落ちた時にワークを再利用したいので、最初に1回行うのみにする）2015.11.16 shibata
		  WorkRentersRoom.destroy_all
		  WorkRentersRoomPicture.destroy_all
		  p '不要データ削除完了'
			
	    p "■■レンターズ自社 開始■■" + Time.now.strftime('%Y%m%d%H%M%S')
	    renters_update_exec(false)
	    p "■■レンターズ自社 終了■■" + Time.now.strftime('%Y%m%d%H%M%S')
	    p "■■レンターズ他社 開始■■" + Time.now.strftime('%Y%m%d%H%M%S')
	    renters_update_exec(true)
	    p "■■レンターズ他社 終了■■" + Time.now.strftime('%Y%m%d%H%M%S')
			
		rescue => e
		  p e.message + " " + Time.now.strftime('%Y/%m/%d %H:%M:%S')
		end
	end
	
	task :renters_reflect_task => :environment  do
		# 自社 false
		# 他社 true
    renters_reflect('B20151127014847', true)
	end
  
  task :generate_report_task => :environment do
    generate_report(false)
    generate_report(true)
  end
    
end

	# 強制実行用	
#	task :renters_update_force => :environment do
#		
#		
#    renters_reflect("B20150606021819", true)
#    p 'データ反映完了'
#
#    # 次回実行日の反映
#		@data_update = DataUpdateTime.find_by_code("315")
#    @data_update.update_datetime = Time.now
#    @data_update.save!
##    @data_update.next_start_date = next_start_date
#		
#	end
  
  # 自社のレンターズアップデート
  def renters_update_exec(sakimono)
    
    if sakimono
      # 他社の時
      @data_update = DataUpdateTime.find_by_code("315")
      sakimono_flg = "'t'"
      #next_start_date = Date.today.next_week(:wednesday) # 翌水曜日
      next_start_date = Date.today.next_day(2)
      
    else
      # 自社の時
      @data_update = DataUpdateTime.find_by_code("310")
      sakimono_flg = "'f'"
      #next_start_date = Date.today.next_week(:tuesday) # 翌火曜日
      next_start_date = Date.today.next_day(2)

    end
    
    # 次回実行日が未来だったら実行しない（空白だったら即時実行）
    if @data_update.next_start_date 
      if @data_update.next_start_date > Date.today
        p "実行日が未来のためスキップ:" + @data_update.next_start_date.to_s 
        return -1
      end
    end
    
    
    
    # 実行日を設定
    batch_cd = Time.now.strftime('%Y%m%d%H%M%S')
    @data_update.start_datetime = Time.now
    @data_update.update_datetime = nil
    # @data_update.next_start_date = nil # 一度次回実行日を初期化  # 2015/10/28 削除
    @data_update.biru_user_id = 1
    @data_update.save!

    # ワークデータの取得
    renters_work_data("B#{batch_cd}", sakimono)
    
    if sakimono
	    p 'ワークデータ取得完了  バッチID:B${batch_cd} 他社フラグ:ON' 
  	else
	    p 'ワークデータ取得完了  バッチID:B${batch_cd} 他社フラグ:OFF' 
    end

    # ワークデータが無事取得できたら初期化
    p '初期化開始（建物）'
	  RentersBuilding.unscoped.joins(:renters_rooms).where("torihiki_mode_sakimono = " + sakimono_flg ).update_all("delete_flg = 't' ") # SQLServerは1
    p '初期化開始（部屋）'
	  RentersRoom.unscoped.where("torihiki_mode_sakimono = " + sakimono_flg ).update_all("delete_flg = 't' ") # SQLServerは1
    p '初期化開始（写真）'
	  RentersRoomPicture.unscoped.joins(:renters_room).where("torihiki_mode_sakimono = " + sakimono_flg ).update_all("delete_flg = 't' ") # SQLServerは1
    p '初期化（部屋）'
    p '初期化完了'

		# レンターズデータへ反映
    renters_reflect("B#{batch_cd}", sakimono)
    p 'データ反映完了'

    # 次回実行日の反映
    @data_update.update_datetime = Time.now
    @data_update.next_start_date = next_start_date
    
    @data_update.save!
    
    p "開始:" + @data_update.start_datetime.to_s + " 終了:" + @data_update.update_datetime.to_s

  end
  
		  
	# ワークデータを作成します(sakimono_flg false=通常、true:先物)
	def renters_work_data(batch_cd, sakimono_flg)
		
	  get_cnt = 50
	  start_idx = 1
	  
    if sakimono_flg
      mode = "&torihiki_mode=6"
    else
      mode = "&torihiki_mode=1,2,3,4,5"
    end
    
	  loop do
	    
	    # url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&count=#{get_cnt.to_s}&start=#{start_idx.to_s}&vacant_div=3,4&torihiki_mode=1,2,3,4")
	    #url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&count=#{get_cnt.to_s}&start=#{start_idx.to_s}&vacant_div=3,4")

	    url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&count=#{get_cnt.to_s}&start=#{start_idx.to_s}&vacant_div=3,4#{mode}")
      
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
	      # p room.elements['room_cd'].text
	      
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
	      
	      #if work_renters_room.building_name
	      #  p work_renters_room.building_name + ' ' + picture_num.to_s + "枚登録"
	      #end
	    end
	  end
	end


	# レンターズデータを本番に反映する
  # (sakimono_flg false=通常、true:先物)
	def renters_reflect(batch_cd, sakimono_flg)
	  	  
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
      room.torihiki_mode_sakimono = sakimono_flg
	    
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
    
  	###########################
  	# 表示テーブルの作成
  	###########################
    generate_report(sakimono_flg)
    
	end



# 実際に使用するレポートの生成
def generate_report(sakimono_flg)

	# renters_reportの初期化
  if sakimono_flg
    RentersReport.unscoped.where("sakimono_flg= 't' ").update_all("delete_flg = 't' ")
  else
    RentersReport.unscoped.where("sakimono_flg= 'f' ").update_all("delete_flg = 't' ")
  end
  
  # renters_reportデータへ反映
  
  p '出力'
  ActiveRecord::Base.connection.select_all(get_renters_sql(false, "", sakimono_flg)).each do |rec|
    
    report = RentersReport.unscoped.find_or_create_by_room_code(rec['room_code'])
    
    report.renters_room_id = rec['renters_room_id']
    report.renters_building_id = rec['renters_building_id']
    report.store_code = rec['store_code']
    report.store_name = rec['store_name']
    report.building_code = rec['building_code']
    report.latitude = rec['latitude']
    report.longitude = rec['longitude']
    report.real_building_name = rec['real_building_name']
    report.real_room_no = rec['real_room_no']
    report.vacant_div = rec['vacant_div']
    report.enter_ym = rec['enter_ym']
    report.address = rec['address']
    report.room_code = rec['room_code']
    report.notice_a = rec['notice_a']
    report.notice_b = rec['notice_b']
    report.notice_c = rec['notice_c']
    report.notice_d = rec['notice_d']
    report.notice_e = rec['notice_e']
    report.notice_f = rec['notice_f']
    report.notice_g = rec['notice_g']
    report.notice_h = rec['notice_h']
    report.madori_renters_madori = rec['J00']
    report.gaikan_renters_gaikan = rec['T00']
    report.naikan_renters_kitchen = rec['J03']
    report.naikan_renters_toilet = rec['J05']
    report.naikan_renters_bus = rec['J04']
    report.naikan_renters_living = rec['J01']
    report.naikan_renters_washroom = rec['J06']
    report.naikan_renters_porch = rec['J02']
    report.naikan_renters_scenery = rec['J07']
    report.naikan_renters_equipment = rec['J08']
    report.naikan_renters_etc = rec['J09']
    report.gaikan_etc_renters_entrance = rec['T04']
    report.gaikan_etc_renters_common_utility = rec['T06']
    report.gaikan_etc_renters_raising_trees = rec['T05']
    report.gaikan_etc_renters_parking = rec['T11']
    report.gaikan_etc_renters_etc = rec['T08']
    report.gaikan_etc_renters_layout = rec['T03']
    report.syuuhen_renters_syuuhen = rec['T01']
		report.renters_all = report.madori_renters_madori + report.gaikan_renters_gaikan + report.naikan_renters_kitchen + report.naikan_renters_toilet + report.naikan_renters_bus + report.naikan_renters_living + report.naikan_renters_washroom + report.naikan_renters_porch + report.naikan_renters_scenery + report.naikan_renters_equipment + report.naikan_renters_etc + report.gaikan_etc_renters_entrance + report.gaikan_etc_renters_common_utility + report.gaikan_etc_renters_raising_trees + report.gaikan_etc_renters_parking + report.gaikan_etc_renters_etc + report.gaikan_etc_renters_layout + report.syuuhen_renters_syuuhen

    #-------------------
		# スーモ枚数カウント
    #-------------------
		
    # 間取り図
		report.suumo_madori = report.madori_renters_madori
		if report.suumo_madori > 1
			report.suumo_madori = 1
    end
		
    # 外観
		report.suumo_gaikan = report.gaikan_renters_gaikan
		if report.suumo_gaikan > 2
			report.suumo_gaikan = 2
    end
				
    # 内観
		report.suumo_naikan = (report.naikan_renters_kitchen + report.naikan_renters_toilet + report.naikan_renters_bus + report.naikan_renters_living + report.naikan_renters_washroom +  report.naikan_renters_porch + report.naikan_renters_scenery + report.naikan_renters_equipment + report.naikan_renters_etc)
		if report.suumo_naikan > 9
			report.suumo_naikan = 9
    end
		
    # 外観その他
		report.suumo_gaikan_etc = (report.gaikan_etc_renters_entrance + report.gaikan_etc_renters_common_utility + report.gaikan_etc_renters_raising_trees + report.gaikan_etc_renters_parking + report.gaikan_etc_renters_etc + report.gaikan_etc_renters_layout)
		if report.suumo_gaikan_etc > 2
			report.suumo_gaikan_etc = 2
    end
		
    # 周辺
		report.suumo_syuuhen = report.syuuhen_renters_syuuhen
		if report.suumo_syuuhen > 6
			report.suumo_syuuhen = 6
    end
		
    # SUUMO合計
		report.suumo_all = report.suumo_madori + report.suumo_gaikan + report.suumo_naikan + report.suumo_gaikan_etc + report.suumo_syuuhen

    
    report.sakimono_flg = sakimono_flg
    report.delete_flg = false
    report.save!
    
#    p report
    
  end
  
  
  # 
  

end

# order : 並べ替えの指定
def get_renters_sql(order, store_list, sakimono_flg)
  
  
  # ,J00 as madori
  # ,T00 as gaikan
  # ,J01 + J02 + J03 + J04 + J05 + J06 + J08 + J09 as naikan
  # ,T03 + T04 + T05 + T06 + T08 + T11 as gaikan_etc
  # ,T01 as syuuhen
  # ,J00 + J00 + J01 + J02 + J03 + J04 + J05 + J06 + J07 + J08 + J09 + T00 + T01 + T02 + T03 + T04 + T05 + T06 + T07 + T08 + T09 + T10 + T11 as all_sum
  
  
  strSql = "
  select
  renters_room_id
  ,store_code
  ,store_name
  ,room_code 
  ,real_building_name
  ,real_room_no
  ,building_code
  ,renters_building_id
  ,vacant_div
  ,enter_ym
  ,address
  ,notice_a
  ,notice_b
  ,notice_c
  ,notice_d
  ,notice_e
  ,notice_f
  ,notice_g
  ,notice_h
  ,latitude
  ,longitude
  ,J00
  ,T00
  ,J01
  ,J02
  ,J03
  ,J04
  ,J05
  ,J06
  ,J08
  ,J07
  ,J09
  ,T03
  ,T04
  ,T05
  ,T06
  ,T08
  ,T11
  ,T01
  from (
  select 
  a.id as renters_room_id
  ,a.store_code
  ,a.store_name
  ,a.room_code 
  ,a.real_building_name
  ,a.real_room_no
  ,a.vacant_div
  ,a.enter_ym
  ,a.building_code
  ,a.notice_a
  ,a.notice_b
  ,a.notice_c
  ,a.notice_d
  ,a.notice_e
  ,a.notice_f
  ,a.notice_g
  ,a.notice_h
  ,c.id as renters_building_id
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
  where a.delete_flg = 'f'
  and b.delete_flg = 'f'
  and c.delete_flg = 'f'
  "
  
  if sakimono_flg
    strSql = strSql + " and torihiki_mode_sakimono = 't'"
  else
    strSql = strSql + " and torihiki_mode_sakimono = 'f'"
  end
  
  if store_list.length > 0
    strSql = strSql + " and store_code IN (" + store_list + ") "
  end
  
  strSql = strSql + "
  group by a.id
  ,a.store_code
  ,a.store_name
  ,a.room_code 
  ,a.real_building_name
  ,a.real_room_no
  ,a.vacant_div
  ,a.enter_ym
  ,a.building_code
  ,a.notice_a
  ,a.notice_b
  ,a.notice_c
  ,a.notice_d
  ,a.notice_e
  ,a.notice_f
  ,a.notice_g
  ,a.notice_h
  ,c.id
  ,c.address
  ,c.latitude
  ,c.longitude
  ) x
  "
  
  if order
    strSql = strSql + " order by building_code"
  end
  
  strSql
  
end
