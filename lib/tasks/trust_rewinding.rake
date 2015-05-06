# -*- coding:utf-8 -*-

require 'csv'
require 'kconv'
require 'date'
#require "moji"


namespace :biruweb do
	
	task :trust_rewinding_update => :environment  do
		
	  # 登録開始日の保存
	  @data_update = DataUpdateTime.find_by_code("500")
	  @data_update.start_datetime = Time.now
	  @data_update.update_datetime = nil
	  @data_update.biru_user_id = 1
	  @data_update.save!

	  cnt = 0
	  unknown_cnt = 0
	  skip_cnt = 0

	  # 委託の定期メンテナンスの登録
	  str_sql = ""
	  str_sql = str_sql + "SELECT "
	  str_sql = str_sql + " 管理委託契約CD "
	  str_sql = str_sql + "FROM V_管理受託_巻き直し完了 "
	  ActiveRecord::Base.connection.select_all(str_sql).each do |rec|

	      # 委託契約の取得
	      itcd = rec['管理委託契約CD'].to_i.to_s
	      trust_rewinding = TrustRewinding.find_by_trust_code(itcd)
	      if trust_rewinding
		      if trust_rewinding.status == 0
		      	  trust_rewinding.status = 1 # 巻き直し完了へ
		      	  trust_rewinding.save!
			      cnt = cnt + 1
			      p "登録更新　 委託コード：" + itcd
			  else
			  	  skip_cnt = skip_cnt + 1
		        p "すでに完了登録済みの為スキップ。 委託コード：" + itcd
	      	  end
	      else
	        p "不明な委託契約が指定されました。 委託コード：" + itcd
	        unknown_cnt = unknown_cnt + 1
	      end
	  end	
			
	  p "出力結果:登録：" + cnt.to_s + '　不明：' + unknown_cnt.to_s + '件'
	  
	  # 登録完了日を保存
	  @data_update.update_datetime = Time.now
	  @data_update.save!
	    
	end

end
