# -*- coding:utf-8 -*-

require 'csv'
require 'kconv'
require 'date'
#require "moji"


namespace :biruweb do
	
	task :trust_attack_update => :environment  do
		
    # カレント月を表示
    app = ApplicationController.new
    month = app.get_cur_month(1)
    @data_update = TrustAttackMonthReportUpdateHistory.find_or_create_by_month(month)
    
	  # 登録開始日の保存
    @data_update.month = month
 	  @data_update.start_datetime = Time.now
 	  @data_update.save!

		app_con = TrustManagementsController.new
		
#		p app_con.get_trust_members.keys
		
		app_con.get_trust_members.keys.each do |key|
			app_con.generate_report_info(month, BiruUser.find_by_code(key))
		end
	

 	  # 登録完了日を保存
 	  @data_update.update_datetime = Time.now
 	  @data_update.save!

	end
end
