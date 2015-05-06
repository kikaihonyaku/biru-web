# -*- coding:utf-8 -*-

require 'csv'
require 'kconv'
require 'date'
#require "moji"


namespace :biruweb do
	
	task :trust_attack_update => :environment  do
		
	  # 登録開始日の保存
# 	  @data_update = DataUpdateTime.find_by_code("500")
# 	  @data_update.start_datetime = Time.now
# 	  @data_update.update_datetime = nil
# 	  @data_update.biru_user_id = 1
# 	  @data_update.save!

		app_con = TrustManagementsController.new
		app_con.generate_report_info('201505', BiruUser.find_by_code('6365'))
		app_con.generate_report_info('201505', BiruUser.find_by_code('6464'))
		app_con.generate_report_info('201505', BiruUser.find_by_code('6425'))
		app_con.generate_report_info('201505', BiruUser.find_by_code('7811'))
		app_con.generate_report_info('201505', BiruUser.find_by_code('5313'))
		app_con.generate_report_info('201505', BiruUser.find_by_code('5518'))
		app_con.generate_report_info('201505', BiruUser.find_by_code('4917'))

		app_con.generate_report_info('201505', BiruUser.find_by_code('5928'))



# 	  # 登録完了日を保存
# 	  @data_update.update_datetime = Time.now
# 	  @data_update.save!

	end
end
