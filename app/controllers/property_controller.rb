#-*- encoding:utf-8 -*- 
require 'csv'

# 資産(建物）を表示するコントローラ
class PropertyController < ApplicationController
  
  # 一覧表の生成を行います。
  def generate_prpperty_report
    
    #  集計テーブルの削除
    PropertyReport.delete_all
    
    #################
    # 集計データの作成
    #################

    
    # 営業所単位でレコードの取得(棟数別)
    ActiveRecord::Base.connection.select_all(get_shop_list_sql).each do |rec|
      
      report = PropertyReport.find_or_create_by_shop_code(rec['shop_code'])
      report.shop_code = rec['shop_code']
      report.building_cnt = rec['building_cnt']
      report.room_cnt = rec['shop_room_cnt']
      report.biru_type_mn_cnt = rec['biru_type_mn_cnt']
      
      report.biru_type_bm_cnt = rec['biru_type_bm_cnt']
      report.biru_type_ap_cnt = rec['biru_type_ap_cnt']
      report.biru_type_kdt_cnt = rec['biru_type_kdt_cnt']
      report.biru_type_etc_cnt = rec['biru_type_etc_cnt']

      report.trust_mente_junkai_seisou_cnt = rec['trust_mente_junkai_seisou_cnt']
      report.trust_mente_kyusui_setubi_cnt = rec['trust_mente_kyusui_setubi_cnt']
      report.trust_mente_tyosui_seisou_cnt = rec['trust_mente_tyosui_seisou_cnt']
      report.trust_mente_elevator_hosyu_cnt = rec['trust_mente_elevator_hosyu_cnt']
      report.trust_mente_bouhan_camera_cnt = rec['trust_mente_bouhan_camera_cnt']
            
      report.save!
      
    end
    
    # 営業所単位でレコードの設定(建物種別ごとの間取り別戸数)
    ActiveRecord::Base.connection.select_all(get_biru_list_sql([], true)).each do |rec|
      
      report = PropertyReport.find_or_create_by_shop_code(rec['shop_code'])
      
      ####################
      # 部屋種別ごとの間取り
      ####################
      case rec['room_type_code']
      when '17010' # マンション
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.room_type_17010_1 = report.room_type_17010_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.room_type_17010_2 = report.room_type_17010_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.room_type_17010_3 = report.room_type_17010_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.room_type_17010_4 = report.room_type_17010_4 + 1
        else
          report.room_type_17010_9 = report.room_type_17010_9 + 1
        end
          
      when '17015' # 分譲マンション
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.room_type_17015_1 = report.room_type_17015_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.room_type_17015_2 = report.room_type_17015_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.room_type_17015_3 = report.room_type_17015_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.room_type_17015_4 = report.room_type_17015_4 + 1
        else
          report.room_type_17015_9 = report.room_type_17015_9 + 1
        end
        
      when '17020' # アパート
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.room_type_17020_1 = report.room_type_17020_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.room_type_17020_2 = report.room_type_17020_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.room_type_17020_3 = report.room_type_17020_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.room_type_17020_4 = report.room_type_17020_4 + 1
        else
          report.room_type_17020_9 = report.room_type_17020_9 + 1
        end
        
      when '17025' # 一戸建貸家
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.room_type_17025_1 = report.room_type_17025_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.room_type_17025_2 = report.room_type_17025_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.room_type_17025_3 = report.room_type_17025_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.room_type_17025_4 = report.room_type_17025_4 + 1
        else
          report.room_type_17025_9 = report.room_type_17025_9 + 1
        end
        
      when '17030' # テラスハウス
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.room_type_17030_1 = report.room_type_17030_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.room_type_17030_2 = report.room_type_17030_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.room_type_17030_3 = report.room_type_17030_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.room_type_17030_4 = report.room_type_17030_4 + 1
        else
          report.room_type_17030_9 = report.room_type_17030_9 + 1
        end
        
      when '17035' # メゾネット
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.room_type_17035_1 = report.room_type_17035_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.room_type_17035_2 = report.room_type_17035_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.room_type_17035_3 = report.room_type_17035_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.room_type_17035_4 = report.room_type_17035_4 + 1
        else
          report.room_type_17035_9 = report.room_type_17035_9 + 1
        end
      else # その他
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.room_type_17099_1 = report.room_type_17099_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.room_type_17099_2 = report.room_type_17099_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.room_type_17099_3 = report.room_type_17099_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.room_type_17099_4 = report.room_type_17099_4 + 1
        else
          report.room_type_17099_9 = report.room_type_17099_9 + 1
        end
      end
      
        
      ####################
      # 築年数ごとの間取り
      ####################
      case rec['biru_age']
      when 0..5
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.biru_age_0005_1 = report.biru_age_0005_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.biru_age_0005_2 = report.biru_age_0005_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.biru_age_0005_3 = report.biru_age_0005_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.biru_age_0005_4 = report.biru_age_0005_4 + 1
        else
          report.biru_age_0005_9 = report.biru_age_0005_9 + 1
        end
        
      when 6..10
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.biru_age_0610_1 = report.biru_age_0610_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.biru_age_0610_2 = report.biru_age_0610_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.biru_age_0610_3 = report.biru_age_0610_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.biru_age_0610_4 = report.biru_age_0610_4 + 1
        else
          report.biru_age_0610_9 = report.biru_age_0610_9 + 1
        end
        
      when 11..15
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.biru_age_1115_1 = report.biru_age_1115_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.biru_age_1115_2 = report.biru_age_1115_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.biru_age_1115_3 = report.biru_age_1115_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.biru_age_1115_4 = report.biru_age_1115_4 + 1
        else
          report.biru_age_1115_9 = report.biru_age_1115_9 + 1
        end
      when 16..20
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.biru_age_1620_1 = report.biru_age_1620_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.biru_age_1620_2 = report.biru_age_1620_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.biru_age_1620_3 = report.biru_age_1620_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.biru_age_1620_4 = report.biru_age_1620_4 + 1
        else
          report.biru_age_1620_9 = report.biru_age_1620_9 + 1
        end
      when 21..25
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.biru_age_2125_1 = report.biru_age_2125_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.biru_age_2125_2 = report.biru_age_2125_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.biru_age_2125_3 = report.biru_age_2125_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.biru_age_2125_4 = report.biru_age_2125_4 + 1
        else
          report.biru_age_2125_9 = report.biru_age_2125_9 + 1
        end
      when 26..30
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.biru_age_2630_1 = report.biru_age_2630_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.biru_age_2630_2 = report.biru_age_2630_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.biru_age_2630_3 = report.biru_age_2630_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.biru_age_2630_4 = report.biru_age_2630_4 + 1
        else
          report.biru_age_2630_9 = report.biru_age_2630_9 + 1
        end
      when 31..35
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.biru_age_3135_1 = report.biru_age_3135_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.biru_age_3135_2 = report.biru_age_3135_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.biru_age_3135_3 = report.biru_age_3135_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.biru_age_3135_4 = report.biru_age_3135_4 + 1
        else
          report.biru_age_3135_9 = report.biru_age_3135_9 + 1
        end
      else
        case rec['room_layout_code']
        when '18100', '18105', '18110', '18120', '18125' # 1R〜1LDK
          report.biru_age_9999_1 = report.biru_age_9999_1 + 1
        when '18200', '18205', '18210', '18215', '18220' # 2k〜2LDK
          report.biru_age_9999_2 = report.biru_age_9999_2 + 1
        when '18300', '18305', '18310', '18311', '18315', '18320' # 3k〜3LDK
          report.biru_age_9999_3 = report.biru_age_9999_3 + 1
        when '18400', '18405', '18410', '18415', '18420' # 4k〜4LDK
          report.biru_age_9999_4 = report.biru_age_9999_4 + 1
        else
          report.biru_age_9999_9 = report.biru_age_9999_9 + 1
        end
      end
      
      report.save!
      
    end
    
  end

  # 物件種別のiconを変更する時のコントローラ
  def change_biru_icon
    p 'パラメータ ' + params[:disp_type].to_s
    @biru_icon = params[:disp_type]
  end
  
  def index
    
    @data_update = DataUpdateTime.find_by_code("110")
    
    # 管理物件、巡回清掃、定期メンテ、在宅清掃が入っている一覧表を営業所別に作成
    data_list = []
    arr_tobu = []
    arr_saitama = []
    arr_chiba = []
    arr_unknown = []
    
    ##############################
    # jqgridに渡す営業所別の枠を作成
    ##############################
    group_name = ""
    Shop.all.each do |shop|
      
      case shop.group_id
      when 1
        group_name = "01東武"
        arr_tobu.push(shop.code)
      when 2
        group_name = "02さいたま"
        arr_saitama.push(shop.code)
      when 3
        group_name = "03千葉"
        arr_chiba.push(shop.code)
      else
        group_name = "99その他"
        arr_unknown.push(shop.code)
      end
      
      data_list.push({
        :shop_code => shop.code, :shop_name => shop.name, :group_name => group_name ,:url => 'map?stcd=' + shop.code, :building_cnt => 0 ,:room_cnt => 0, :biru_type_mn_cnt =>0, :biru_type_bm_cnt=>0, :biru_type_ap_cnt => 0, :biru_type_kdt_cnt=>0, :biru_type_etc_cnt=>0, :trust_mente_junkai_seisou_cnt=>0, :trust_mente_kyusui_setubi_cnt=>0, :trust_mente_tyosui_seisou_cnt=>0, :trust_mente_elevator_hosyu_cnt=>0, :trust_mente_bouhan_camera_cnt=>0,:room_type_17010_1 =>0,:room_type_17010_2 =>0,:room_type_17010_3 =>0,:room_type_17010_4 =>0,:room_type_17010_9 =>0,:room_type_17015_1 =>0,:room_type_17015_2 =>0,:room_type_17015_3 =>0,:room_type_17015_4 =>0,:room_type_17015_9 =>0,:room_type_17020_1 =>0,:room_type_17020_2 =>0,:room_type_17020_3 =>0,:room_type_17020_4 =>0,:room_type_17020_9 =>0,:room_type_17025_1 =>0,:room_type_17025_2 =>0,:room_type_17025_3 =>0,:room_type_17025_4 =>0,:room_type_17025_9 =>0,:room_type_17030_1 =>0,:room_type_17030_2 =>0,:room_type_17030_3 =>0,:room_type_17030_4 =>0,:room_type_17030_9 =>0,:room_type_17035_1 =>0,:room_type_17035_2 =>0,:room_type_17035_3 =>0,:room_type_17035_4 =>0,:room_type_17035_9 =>0,:room_type_17099_1 =>0,:room_type_17099_2 =>0,:room_type_17099_3 =>0,:room_type_17099_4 =>0,:room_type_17099_9 =>0,:biru_age_0005_1 =>0,:biru_age_0005_2 =>0,:biru_age_0005_3 =>0,:biru_age_0005_4 =>0,:biru_age_0005_9 =>0,:biru_age_0610_1 =>0,:biru_age_0610_2 =>0,:biru_age_0610_3 =>0,:biru_age_0610_4 =>0,:biru_age_0610_9 =>0,:biru_age_1115_1 =>0,:biru_age_1115_2 =>0,:biru_age_1115_3 =>0,:biru_age_1115_4 =>0,:biru_age_1115_9 =>0,:biru_age_1620_1 =>0,:biru_age_1620_2 =>0,:biru_age_1620_3 =>0,:biru_age_1620_4 =>0,:biru_age_1620_9 =>0,:biru_age_2125_1 =>0,:biru_age_2125_2 =>0,:biru_age_2125_3 =>0,:biru_age_2125_4 =>0,:biru_age_2125_9 =>0,:biru_age_2630_1 =>0,:biru_age_2630_2 =>0,:biru_age_2630_3 =>0,:biru_age_2630_4 =>0,:biru_age_2630_9 =>0,:biru_age_3135_1 =>0,:biru_age_3135_2 =>0,:biru_age_3135_3 =>0,:biru_age_3135_4 =>0,:biru_age_3135_9 =>0,:biru_age_9999_1 =>0,:biru_age_9999_2 =>0,:biru_age_9999_3 =>0,:biru_age_9999_4 =>0,:biru_age_9999_9 =>0
      })
    end
    
    data_list.push({ :shop_code => '100', :shop_name => '東武支店', :group_name => '00支店' ,:url => 'map?stcd=' + arr_tobu.join(','), :building_cnt => 0 ,:room_cnt => 0, :biru_type_mn_cnt =>0, :biru_type_bm_cnt=>0, :biru_type_ap_cnt => 0, :biru_type_kdt_cnt=>0, :biru_type_etc_cnt=>0, :trust_mente_junkai_seisou_cnt=>0, :trust_mente_kyusui_setubi_cnt=>0, :trust_mente_tyosui_seisou_cnt=>0, :trust_mente_elevator_hosyu_cnt=>0, :trust_mente_bouhan_camera_cnt=>0,:room_type_17010_1 =>0,:room_type_17010_2 =>0,:room_type_17010_3 =>0,:room_type_17010_4 =>0,:room_type_17010_9 =>0,:room_type_17015_1 =>0,:room_type_17015_2 =>0,:room_type_17015_3 =>0,:room_type_17015_4 =>0,:room_type_17015_9 =>0,:room_type_17020_1 =>0,:room_type_17020_2 =>0,:room_type_17020_3 =>0,:room_type_17020_4 =>0,:room_type_17020_9 =>0,:room_type_17025_1 =>0,:room_type_17025_2 =>0,:room_type_17025_3 =>0,:room_type_17025_4 =>0,:room_type_17025_9 =>0,:room_type_17030_1 =>0,:room_type_17030_2 =>0,:room_type_17030_3 =>0,:room_type_17030_4 =>0,:room_type_17030_9 =>0,:room_type_17035_1 =>0,:room_type_17035_2 =>0,:room_type_17035_3 =>0,:room_type_17035_4 =>0,:room_type_17035_9 =>0,:room_type_17099_1 =>0,:room_type_17099_2 =>0,:room_type_17099_3 =>0,:room_type_17099_4 =>0,:room_type_17099_9 =>0,:biru_age_0005_1 =>0,:biru_age_0005_2 =>0,:biru_age_0005_3 =>0,:biru_age_0005_4 =>0,:biru_age_0005_9 =>0,:biru_age_0610_1 =>0,:biru_age_0610_2 =>0,:biru_age_0610_3 =>0,:biru_age_0610_4 =>0,:biru_age_0610_9 =>0,:biru_age_1115_1 =>0,:biru_age_1115_2 =>0,:biru_age_1115_3 =>0,:biru_age_1115_4 =>0,:biru_age_1115_9 =>0,:biru_age_1620_1 =>0,:biru_age_1620_2 =>0,:biru_age_1620_3 =>0,:biru_age_1620_4 =>0,:biru_age_1620_9 =>0,:biru_age_2125_1 =>0,:biru_age_2125_2 =>0,:biru_age_2125_3 =>0,:biru_age_2125_4 =>0,:biru_age_2125_9 =>0,:biru_age_2630_1 =>0,:biru_age_2630_2 =>0,:biru_age_2630_3 =>0,:biru_age_2630_4 =>0,:biru_age_2630_9 =>0,:biru_age_3135_1 =>0,:biru_age_3135_2 =>0,:biru_age_3135_3 =>0,:biru_age_3135_4 =>0,:biru_age_3135_9 =>0,:biru_age_9999_1 =>0,:biru_age_9999_2 =>0,:biru_age_9999_3 =>0,:biru_age_9999_4 =>0,:biru_age_9999_9 =>0})
    data_list.push({ :shop_code => '200', :shop_name => 'さいたま支店', :group_name => '00支店' ,:url => 'map?stcd=' + arr_saitama.join(','), :building_cnt => 0 ,:room_cnt => 0, :biru_type_mn_cnt =>0, :biru_type_bm_cnt=>0, :biru_type_ap_cnt => 0, :biru_type_kdt_cnt=>0, :biru_type_etc_cnt=>0, :trust_mente_junkai_seisou_cnt=>0, :trust_mente_kyusui_setubi_cnt=>0, :trust_mente_tyosui_seisou_cnt=>0, :trust_mente_elevator_hosyu_cnt=>0, :trust_mente_bouhan_camera_cnt=>0,:room_type_17010_1 =>0,:room_type_17010_2 =>0,:room_type_17010_3 =>0,:room_type_17010_4 =>0,:room_type_17010_9 =>0,:room_type_17015_1 =>0,:room_type_17015_2 =>0,:room_type_17015_3 =>0,:room_type_17015_4 =>0,:room_type_17015_9 =>0,:room_type_17020_1 =>0,:room_type_17020_2 =>0,:room_type_17020_3 =>0,:room_type_17020_4 =>0,:room_type_17020_9 =>0,:room_type_17025_1 =>0,:room_type_17025_2 =>0,:room_type_17025_3 =>0,:room_type_17025_4 =>0,:room_type_17025_9 =>0,:room_type_17030_1 =>0,:room_type_17030_2 =>0,:room_type_17030_3 =>0,:room_type_17030_4 =>0,:room_type_17030_9 =>0,:room_type_17035_1 =>0,:room_type_17035_2 =>0,:room_type_17035_3 =>0,:room_type_17035_4 =>0,:room_type_17035_9 =>0,:room_type_17099_1 =>0,:room_type_17099_2 =>0,:room_type_17099_3 =>0,:room_type_17099_4 =>0,:room_type_17099_9 =>0,:biru_age_0005_1 =>0,:biru_age_0005_2 =>0,:biru_age_0005_3 =>0,:biru_age_0005_4 =>0,:biru_age_0005_9 =>0,:biru_age_0610_1 =>0,:biru_age_0610_2 =>0,:biru_age_0610_3 =>0,:biru_age_0610_4 =>0,:biru_age_0610_9 =>0,:biru_age_1115_1 =>0,:biru_age_1115_2 =>0,:biru_age_1115_3 =>0,:biru_age_1115_4 =>0,:biru_age_1115_9 =>0,:biru_age_1620_1 =>0,:biru_age_1620_2 =>0,:biru_age_1620_3 =>0,:biru_age_1620_4 =>0,:biru_age_1620_9 =>0,:biru_age_2125_1 =>0,:biru_age_2125_2 =>0,:biru_age_2125_3 =>0,:biru_age_2125_4 =>0,:biru_age_2125_9 =>0,:biru_age_2630_1 =>0,:biru_age_2630_2 =>0,:biru_age_2630_3 =>0,:biru_age_2630_4 =>0,:biru_age_2630_9 =>0,:biru_age_3135_1 =>0,:biru_age_3135_2 =>0,:biru_age_3135_3 =>0,:biru_age_3135_4 =>0,:biru_age_3135_9 =>0,:biru_age_9999_1 =>0,:biru_age_9999_2 =>0,:biru_age_9999_3 =>0,:biru_age_9999_4 =>0,:biru_age_9999_9 =>0 })
    data_list.push({ :shop_code => '300', :shop_name => '千葉支店', :group_name => '00支店' ,:url => 'map?stcd=' + arr_chiba.join(','), :building_cnt => 0 ,:room_cnt => 0, :biru_type_mn_cnt =>0, :biru_type_bm_cnt=>0, :biru_type_ap_cnt => 0, :biru_type_kdt_cnt=>0, :biru_type_etc_cnt=>0, :trust_mente_junkai_seisou_cnt=>0, :trust_mente_kyusui_setubi_cnt=>0, :trust_mente_tyosui_seisou_cnt=>0, :trust_mente_elevator_hosyu_cnt=>0, :trust_mente_bouhan_camera_cnt=>0,:room_type_17010_1 =>0,:room_type_17010_2 =>0,:room_type_17010_3 =>0,:room_type_17010_4 =>0,:room_type_17010_9 =>0,:room_type_17015_1 =>0,:room_type_17015_2 =>0,:room_type_17015_3 =>0,:room_type_17015_4 =>0,:room_type_17015_9 =>0,:room_type_17020_1 =>0,:room_type_17020_2 =>0,:room_type_17020_3 =>0,:room_type_17020_4 =>0,:room_type_17020_9 =>0,:room_type_17025_1 =>0,:room_type_17025_2 =>0,:room_type_17025_3 =>0,:room_type_17025_4 =>0,:room_type_17025_9 =>0,:room_type_17030_1 =>0,:room_type_17030_2 =>0,:room_type_17030_3 =>0,:room_type_17030_4 =>0,:room_type_17030_9 =>0,:room_type_17035_1 =>0,:room_type_17035_2 =>0,:room_type_17035_3 =>0,:room_type_17035_4 =>0,:room_type_17035_9 =>0,:room_type_17099_1 =>0,:room_type_17099_2 =>0,:room_type_17099_3 =>0,:room_type_17099_4 =>0,:room_type_17099_9 =>0,:biru_age_0005_1 =>0,:biru_age_0005_2 =>0,:biru_age_0005_3 =>0,:biru_age_0005_4 =>0,:biru_age_0005_9 =>0,:biru_age_0610_1 =>0,:biru_age_0610_2 =>0,:biru_age_0610_3 =>0,:biru_age_0610_4 =>0,:biru_age_0610_9 =>0,:biru_age_1115_1 =>0,:biru_age_1115_2 =>0,:biru_age_1115_3 =>0,:biru_age_1115_4 =>0,:biru_age_1115_9 =>0,:biru_age_1620_1 =>0,:biru_age_1620_2 =>0,:biru_age_1620_3 =>0,:biru_age_1620_4 =>0,:biru_age_1620_9 =>0,:biru_age_2125_1 =>0,:biru_age_2125_2 =>0,:biru_age_2125_3 =>0,:biru_age_2125_4 =>0,:biru_age_2125_9 =>0,:biru_age_2630_1 =>0,:biru_age_2630_2 =>0,:biru_age_2630_3 =>0,:biru_age_2630_4 =>0,:biru_age_2630_9 =>0,:biru_age_3135_1 =>0,:biru_age_3135_2 =>0,:biru_age_3135_3 =>0,:biru_age_3135_4 =>0,:biru_age_3135_9 =>0,:biru_age_9999_1 =>0,:biru_age_9999_2 =>0,:biru_age_9999_3 =>0,:biru_age_9999_4 =>0,:biru_age_9999_9 =>0})
    data_list.push({ :shop_code => '900', :shop_name => 'ビル全体', :group_name => '99その他' ,:url => 'map', :building_cnt => 0 ,:room_cnt => 0, :biru_type_mn_cnt =>0, :biru_type_bm_cnt=>0, :biru_type_ap_cnt => 0, :biru_type_kdt_cnt=>0, :biru_type_etc_cnt=>0, :trust_mente_junkai_seisou_cnt=>0, :trust_mente_kyusui_setubi_cnt=>0, :trust_mente_tyosui_seisou_cnt=>0, :trust_mente_elevator_hosyu_cnt=>0, :trust_mente_bouhan_camera_cnt=>0,:room_type_17010_1 =>0,:room_type_17010_2 =>0,:room_type_17010_3 =>0,:room_type_17010_4 =>0,:room_type_17010_9 =>0,:room_type_17015_1 =>0,:room_type_17015_2 =>0,:room_type_17015_3 =>0,:room_type_17015_4 =>0,:room_type_17015_9 =>0,:room_type_17020_1 =>0,:room_type_17020_2 =>0,:room_type_17020_3 =>0,:room_type_17020_4 =>0,:room_type_17020_9 =>0,:room_type_17025_1 =>0,:room_type_17025_2 =>0,:room_type_17025_3 =>0,:room_type_17025_4 =>0,:room_type_17025_9 =>0,:room_type_17030_1 =>0,:room_type_17030_2 =>0,:room_type_17030_3 =>0,:room_type_17030_4 =>0,:room_type_17030_9 =>0,:room_type_17035_1 =>0,:room_type_17035_2 =>0,:room_type_17035_3 =>0,:room_type_17035_4 =>0,:room_type_17035_9 =>0,:room_type_17099_1 =>0,:room_type_17099_2 =>0,:room_type_17099_3 =>0,:room_type_17099_4 =>0,:room_type_17099_9 =>0,:biru_age_0005_1 =>0,:biru_age_0005_2 =>0,:biru_age_0005_3 =>0,:biru_age_0005_4 =>0,:biru_age_0005_9 =>0,:biru_age_0610_1 =>0,:biru_age_0610_2 =>0,:biru_age_0610_3 =>0,:biru_age_0610_4 =>0,:biru_age_0610_9 =>0,:biru_age_1115_1 =>0,:biru_age_1115_2 =>0,:biru_age_1115_3 =>0,:biru_age_1115_4 =>0,:biru_age_1115_9 =>0,:biru_age_1620_1 =>0,:biru_age_1620_2 =>0,:biru_age_1620_3 =>0,:biru_age_1620_4 =>0,:biru_age_1620_9 =>0,:biru_age_2125_1 =>0,:biru_age_2125_2 =>0,:biru_age_2125_3 =>0,:biru_age_2125_4 =>0,:biru_age_2125_9 =>0,:biru_age_2630_1 =>0,:biru_age_2630_2 =>0,:biru_age_2630_3 =>0,:biru_age_2630_4 =>0,:biru_age_2630_9 =>0,:biru_age_3135_1 =>0,:biru_age_3135_2 =>0,:biru_age_3135_3 =>0,:biru_age_3135_4 =>0,:biru_age_3135_9 =>0,:biru_age_9999_1 =>0,:biru_age_9999_2 =>0,:biru_age_9999_3 =>0,:biru_age_9999_4 =>0,:biru_age_9999_9 =>0})

    ##############################
    # 営業所データをハッシュに格納
    ##############################
    grid_data = {}
    #ActiveRecord::Base.connection.select_all(get_shop_list_sql).each do |rec|
    ActiveRecord::Base.connection.select_all("select * from property_reports").each do |rec|
      unless grid_data[rec['shop_code']]
        
        grid_data[rec['shop_code']] = {
           :shop_code => rec['shop_code'],
           :building_cnt => rec['building_cnt'],
           :room_cnt => rec['room_cnt'],
           
           :biru_type_mn_cnt => rec['biru_type_mn_cnt'],
           :biru_type_bm_cnt => rec['biru_type_bm_cnt'],
           :biru_type_ap_cnt => rec['biru_type_ap_cnt'],
           :biru_type_kdt_cnt => rec['biru_type_kdt_cnt'],
           :biru_type_etc_cnt => rec['biru_type_etc_cnt'],
           
           :trust_mente_junkai_seisou_cnt => rec['trust_mente_junkai_seisou_cnt'],
           :trust_mente_kyusui_setubi_cnt => rec['trust_mente_kyusui_setubi_cnt'],
           :trust_mente_tyosui_seisou_cnt => rec['trust_mente_tyosui_seisou_cnt'],
           :trust_mente_elevator_hosyu_cnt => rec['trust_mente_elevator_hosyu_cnt'],
           :trust_mente_bouhan_camera_cnt => rec['trust_mente_bouhan_camera_cnt'],
           
           :room_type_17010_1 => rec['room_type_17010_1'],
           :room_type_17010_2 => rec['room_type_17010_2'],
           :room_type_17010_3 => rec['room_type_17010_3'],
           :room_type_17010_4 => rec['room_type_17010_4'],
           :room_type_17010_9 => rec['room_type_17010_9'],
           :room_type_17015_1 => rec['room_type_17015_1'],
           :room_type_17015_2 => rec['room_type_17015_2'],
           :room_type_17015_3 => rec['room_type_17015_3'],
           :room_type_17015_4 => rec['room_type_17015_4'],
           :room_type_17015_9 => rec['room_type_17015_9'],
           :room_type_17020_1 => rec['room_type_17020_1'],
           :room_type_17020_2 => rec['room_type_17020_2'],
           :room_type_17020_3 => rec['room_type_17020_3'],
           :room_type_17020_4 => rec['room_type_17020_4'],
           :room_type_17020_9 => rec['room_type_17020_9'],
           :room_type_17025_1 => rec['room_type_17025_1'],
           :room_type_17025_2 => rec['room_type_17025_2'],
           :room_type_17025_3 => rec['room_type_17025_3'],
           :room_type_17025_4 => rec['room_type_17025_4'],
           :room_type_17025_9 => rec['room_type_17025_9'],
           :room_type_17030_1 => rec['room_type_17030_1'],
           :room_type_17030_2 => rec['room_type_17030_2'],
           :room_type_17030_3 => rec['room_type_17030_3'],
           :room_type_17030_4 => rec['room_type_17030_4'],
           :room_type_17030_9 => rec['room_type_17030_9'],
           :room_type_17035_1 => rec['room_type_17035_1'],
           :room_type_17035_2 => rec['room_type_17035_2'],
           :room_type_17035_3 => rec['room_type_17035_3'],
           :room_type_17035_4 => rec['room_type_17035_4'],
           :room_type_17035_9 => rec['room_type_17035_9'],
           :room_type_17099_1 => rec['room_type_17099_1'],
           :room_type_17099_2 => rec['room_type_17099_2'],
           :room_type_17099_3 => rec['room_type_17099_3'],
           :room_type_17099_4 => rec['room_type_17099_4'],
           :room_type_17099_9 => rec['room_type_17099_9'],
           :biru_age_0005_1 => rec['biru_age_0005_1'],
           :biru_age_0005_2 => rec['biru_age_0005_2'],
           :biru_age_0005_3 => rec['biru_age_0005_3'],
           :biru_age_0005_4 => rec['biru_age_0005_4'],
           :biru_age_0005_9 => rec['biru_age_0005_9'],
           :biru_age_0610_1 => rec['biru_age_0610_1'],
           :biru_age_0610_2 => rec['biru_age_0610_2'],
           :biru_age_0610_3 => rec['biru_age_0610_3'],
           :biru_age_0610_4 => rec['biru_age_0610_4'],
           :biru_age_0610_9 => rec['biru_age_0610_9'],
           :biru_age_1115_1 => rec['biru_age_1115_1'],
           :biru_age_1115_2 => rec['biru_age_1115_2'],
           :biru_age_1115_3 => rec['biru_age_1115_3'],
           :biru_age_1115_4 => rec['biru_age_1115_4'],
           :biru_age_1115_9 => rec['biru_age_1115_9'],
           :biru_age_1620_1 => rec['biru_age_1620_1'],
           :biru_age_1620_2 => rec['biru_age_1620_2'],
           :biru_age_1620_3 => rec['biru_age_1620_3'],
           :biru_age_1620_4 => rec['biru_age_1620_4'],
           :biru_age_1620_9 => rec['biru_age_1620_9'],
           :biru_age_2125_1 => rec['biru_age_2125_1'],
           :biru_age_2125_2 => rec['biru_age_2125_2'],
           :biru_age_2125_3 => rec['biru_age_2125_3'],
           :biru_age_2125_4 => rec['biru_age_2125_4'],
           :biru_age_2125_9 => rec['biru_age_2125_9'],
           :biru_age_2630_1 => rec['biru_age_2630_1'],
           :biru_age_2630_2 => rec['biru_age_2630_2'],
           :biru_age_2630_3 => rec['biru_age_2630_3'],
           :biru_age_2630_4 => rec['biru_age_2630_4'],
           :biru_age_2630_9 => rec['biru_age_2630_9'],
           :biru_age_3135_1 => rec['biru_age_3135_1'],
           :biru_age_3135_2 => rec['biru_age_3135_2'],
           :biru_age_3135_3 => rec['biru_age_3135_3'],
           :biru_age_3135_4 => rec['biru_age_3135_4'],
           :biru_age_3135_9 => rec['biru_age_3135_9'],
           :biru_age_9999_1 => rec['biru_age_9999_1'],
           :biru_age_9999_2 => rec['biru_age_9999_2'],
           :biru_age_9999_3 => rec['biru_age_9999_3'],
           :biru_age_9999_4 => rec['biru_age_9999_4'],
           :biru_age_9999_9 => rec['biru_age_9999_9'],

           
         }
      end
    end
    
    ##############################
    # 営業所の枠に取得した値を格納
    ##############################
    toubu_hash = {
      :building_cnt =>0,
      :room_cnt =>0,
      :biru_type_mn_cnt => 0,
      :biru_type_bm_cnt => 0,
      :biru_type_ap_cnt => 0,
      :biru_type_kdt_cnt => 0,
      :biru_type_etc_cnt => 0,

      :trust_mente_junkai_seisou_cnt => 0,
      :trust_mente_kyusui_setubi_cnt => 0,
      :trust_mente_tyosui_seisou_cnt => 0,
      :trust_mente_elevator_hosyu_cnt => 0,
      :trust_mente_bouhan_camera_cnt => 0,
      :room_type_17010_1	 => 0,
      :room_type_17010_2	 => 0,
      :room_type_17010_3	 => 0,
      :room_type_17010_4	 => 0,
      :room_type_17010_9	 => 0,
      :room_type_17015_1	 => 0,
      :room_type_17015_2	 => 0,
      :room_type_17015_3	 => 0,
      :room_type_17015_4	 => 0,
      :room_type_17015_9	 => 0,
      :room_type_17020_1	 => 0,
      :room_type_17020_2	 => 0,
      :room_type_17020_3	 => 0,
      :room_type_17020_4	 => 0,
      :room_type_17020_9	 => 0,
      :room_type_17025_1	 => 0,
      :room_type_17025_2	 => 0,
      :room_type_17025_3	 => 0,
      :room_type_17025_4	 => 0,
      :room_type_17025_9	 => 0,
      :room_type_17030_1	 => 0,
      :room_type_17030_2	 => 0,
      :room_type_17030_3	 => 0,
      :room_type_17030_4	 => 0,
      :room_type_17030_9	 => 0,
      :room_type_17035_1	 => 0,
      :room_type_17035_2	 => 0,
      :room_type_17035_3	 => 0,
      :room_type_17035_4	 => 0,
      :room_type_17035_9	 => 0,
      :room_type_17099_1	 => 0,
      :room_type_17099_2	 => 0,
      :room_type_17099_3	 => 0,
      :room_type_17099_4	 => 0,
      :room_type_17099_9	 => 0,
      :biru_age_0005_1	 => 0,
      :biru_age_0005_2	 => 0,
      :biru_age_0005_3	 => 0,
      :biru_age_0005_4	 => 0,
      :biru_age_0005_9	 => 0,
      :biru_age_0610_1	 => 0,
      :biru_age_0610_2	 => 0,
      :biru_age_0610_3	 => 0,
      :biru_age_0610_4	 => 0,
      :biru_age_0610_9	 => 0,
      :biru_age_1115_1	 => 0,
      :biru_age_1115_2	 => 0,
      :biru_age_1115_3	 => 0,
      :biru_age_1115_4	 => 0,
      :biru_age_1115_9	 => 0,
      :biru_age_1620_1	 => 0,
      :biru_age_1620_2	 => 0,
      :biru_age_1620_3	 => 0,
      :biru_age_1620_4	 => 0,
      :biru_age_1620_9	 => 0,
      :biru_age_2125_1	 => 0,
      :biru_age_2125_2	 => 0,
      :biru_age_2125_3	 => 0,
      :biru_age_2125_4	 => 0,
      :biru_age_2125_9	 => 0,
      :biru_age_2630_1	 => 0,
      :biru_age_2630_2	 => 0,
      :biru_age_2630_3	 => 0,
      :biru_age_2630_4	 => 0,
      :biru_age_2630_9	 => 0,
      :biru_age_3135_1	 => 0,
      :biru_age_3135_2	 => 0,
      :biru_age_3135_3	 => 0,
      :biru_age_3135_4	 => 0,
      :biru_age_3135_9	 => 0,
      :biru_age_9999_1	 => 0,
      :biru_age_9999_2	 => 0,
      :biru_age_9999_3	 => 0,
      :biru_age_9999_4	 => 0,
      :biru_age_9999_9	 => 0,

    }
    
    saitama_hash = {
      :building_cnt =>0,
      :room_cnt =>0,
      :biru_type_mn_cnt => 0,
      :biru_type_bm_cnt => 0,
      :biru_type_ap_cnt => 0,
      :biru_type_kdt_cnt => 0,
      :biru_type_etc_cnt => 0,
      
      :trust_mente_junkai_seisou_cnt => 0,
      :trust_mente_kyusui_setubi_cnt => 0,
      :trust_mente_tyosui_seisou_cnt => 0,
      :trust_mente_elevator_hosyu_cnt => 0,
      :trust_mente_bouhan_camera_cnt => 0,
      
      :room_type_17010_1	 => 0,
      :room_type_17010_2	 => 0,
      :room_type_17010_3	 => 0,
      :room_type_17010_4	 => 0,
      :room_type_17010_9	 => 0,
      :room_type_17015_1	 => 0,
      :room_type_17015_2	 => 0,
      :room_type_17015_3	 => 0,
      :room_type_17015_4	 => 0,
      :room_type_17015_9	 => 0,
      :room_type_17020_1	 => 0,
      :room_type_17020_2	 => 0,
      :room_type_17020_3	 => 0,
      :room_type_17020_4	 => 0,
      :room_type_17020_9	 => 0,
      :room_type_17025_1	 => 0,
      :room_type_17025_2	 => 0,
      :room_type_17025_3	 => 0,
      :room_type_17025_4	 => 0,
      :room_type_17025_9	 => 0,
      :room_type_17030_1	 => 0,
      :room_type_17030_2	 => 0,
      :room_type_17030_3	 => 0,
      :room_type_17030_4	 => 0,
      :room_type_17030_9	 => 0,
      :room_type_17035_1	 => 0,
      :room_type_17035_2	 => 0,
      :room_type_17035_3	 => 0,
      :room_type_17035_4	 => 0,
      :room_type_17035_9	 => 0,
      :room_type_17099_1	 => 0,
      :room_type_17099_2	 => 0,
      :room_type_17099_3	 => 0,
      :room_type_17099_4	 => 0,
      :room_type_17099_9	 => 0,
      :biru_age_0005_1	 => 0,
      :biru_age_0005_2	 => 0,
      :biru_age_0005_3	 => 0,
      :biru_age_0005_4	 => 0,
      :biru_age_0005_9	 => 0,
      :biru_age_0610_1	 => 0,
      :biru_age_0610_2	 => 0,
      :biru_age_0610_3	 => 0,
      :biru_age_0610_4	 => 0,
      :biru_age_0610_9	 => 0,
      :biru_age_1115_1	 => 0,
      :biru_age_1115_2	 => 0,
      :biru_age_1115_3	 => 0,
      :biru_age_1115_4	 => 0,
      :biru_age_1115_9	 => 0,
      :biru_age_1620_1	 => 0,
      :biru_age_1620_2	 => 0,
      :biru_age_1620_3	 => 0,
      :biru_age_1620_4	 => 0,
      :biru_age_1620_9	 => 0,
      :biru_age_2125_1	 => 0,
      :biru_age_2125_2	 => 0,
      :biru_age_2125_3	 => 0,
      :biru_age_2125_4	 => 0,
      :biru_age_2125_9	 => 0,
      :biru_age_2630_1	 => 0,
      :biru_age_2630_2	 => 0,
      :biru_age_2630_3	 => 0,
      :biru_age_2630_4	 => 0,
      :biru_age_2630_9	 => 0,
      :biru_age_3135_1	 => 0,
      :biru_age_3135_2	 => 0,
      :biru_age_3135_3	 => 0,
      :biru_age_3135_4	 => 0,
      :biru_age_3135_9	 => 0,
      :biru_age_9999_1	 => 0,
      :biru_age_9999_2	 => 0,
      :biru_age_9999_3	 => 0,
      :biru_age_9999_4	 => 0,
      :biru_age_9999_9	 => 0,
    }

    chiba_hash = {
      :building_cnt =>0,
      :room_cnt =>0,
      :biru_type_mn_cnt => 0,
      :biru_type_bm_cnt => 0,
      :biru_type_ap_cnt => 0,
      :biru_type_kdt_cnt => 0,
      :biru_type_etc_cnt => 0,
      
      :trust_mente_junkai_seisou_cnt => 0,
      :trust_mente_kyusui_setubi_cnt => 0,
      :trust_mente_tyosui_seisou_cnt => 0,
      :trust_mente_elevator_hosyu_cnt => 0,
      :trust_mente_bouhan_camera_cnt => 0,
      
      :room_type_17010_1	 => 0,
      :room_type_17010_2	 => 0,
      :room_type_17010_3	 => 0,
      :room_type_17010_4	 => 0,
      :room_type_17010_9	 => 0,
      :room_type_17015_1	 => 0,
      :room_type_17015_2	 => 0,
      :room_type_17015_3	 => 0,
      :room_type_17015_4	 => 0,
      :room_type_17015_9	 => 0,
      :room_type_17020_1	 => 0,
      :room_type_17020_2	 => 0,
      :room_type_17020_3	 => 0,
      :room_type_17020_4	 => 0,
      :room_type_17020_9	 => 0,
      :room_type_17025_1	 => 0,
      :room_type_17025_2	 => 0,
      :room_type_17025_3	 => 0,
      :room_type_17025_4	 => 0,
      :room_type_17025_9	 => 0,
      :room_type_17030_1	 => 0,
      :room_type_17030_2	 => 0,
      :room_type_17030_3	 => 0,
      :room_type_17030_4	 => 0,
      :room_type_17030_9	 => 0,
      :room_type_17035_1	 => 0,
      :room_type_17035_2	 => 0,
      :room_type_17035_3	 => 0,
      :room_type_17035_4	 => 0,
      :room_type_17035_9	 => 0,
      :room_type_17099_1	 => 0,
      :room_type_17099_2	 => 0,
      :room_type_17099_3	 => 0,
      :room_type_17099_4	 => 0,
      :room_type_17099_9	 => 0,
      :biru_age_0005_1	 => 0,
      :biru_age_0005_2	 => 0,
      :biru_age_0005_3	 => 0,
      :biru_age_0005_4	 => 0,
      :biru_age_0005_9	 => 0,
      :biru_age_0610_1	 => 0,
      :biru_age_0610_2	 => 0,
      :biru_age_0610_3	 => 0,
      :biru_age_0610_4	 => 0,
      :biru_age_0610_9	 => 0,
      :biru_age_1115_1	 => 0,
      :biru_age_1115_2	 => 0,
      :biru_age_1115_3	 => 0,
      :biru_age_1115_4	 => 0,
      :biru_age_1115_9	 => 0,
      :biru_age_1620_1	 => 0,
      :biru_age_1620_2	 => 0,
      :biru_age_1620_3	 => 0,
      :biru_age_1620_4	 => 0,
      :biru_age_1620_9	 => 0,
      :biru_age_2125_1	 => 0,
      :biru_age_2125_2	 => 0,
      :biru_age_2125_3	 => 0,
      :biru_age_2125_4	 => 0,
      :biru_age_2125_9	 => 0,
      :biru_age_2630_1	 => 0,
      :biru_age_2630_2	 => 0,
      :biru_age_2630_3	 => 0,
      :biru_age_2630_4	 => 0,
      :biru_age_2630_9	 => 0,
      :biru_age_3135_1	 => 0,
      :biru_age_3135_2	 => 0,
      :biru_age_3135_3	 => 0,
      :biru_age_3135_4	 => 0,
      :biru_age_3135_9	 => 0,
      :biru_age_9999_1	 => 0,
      :biru_age_9999_2	 => 0,
      :biru_age_9999_3	 => 0,
      :biru_age_9999_4	 => 0,
      :biru_age_9999_9	 => 0,
    }

    etc_hash = {
      :building_cnt =>0,
      :room_cnt =>0,
      :biru_type_mn_cnt => 0,
      :biru_type_bm_cnt => 0,
      :biru_type_ap_cnt => 0,
      :biru_type_kdt_cnt => 0,
      :biru_type_etc_cnt => 0,
      
      :trust_mente_junkai_seisou_cnt => 0,
      :trust_mente_kyusui_setubi_cnt => 0,
      :trust_mente_tyosui_seisou_cnt => 0,
      :trust_mente_elevator_hosyu_cnt => 0,
      :trust_mente_bouhan_camera_cnt => 0,
      
      :room_type_17010_1	 => 0,
      :room_type_17010_2	 => 0,
      :room_type_17010_3	 => 0,
      :room_type_17010_4	 => 0,
      :room_type_17010_9	 => 0,
      :room_type_17015_1	 => 0,
      :room_type_17015_2	 => 0,
      :room_type_17015_3	 => 0,
      :room_type_17015_4	 => 0,
      :room_type_17015_9	 => 0,
      :room_type_17020_1	 => 0,
      :room_type_17020_2	 => 0,
      :room_type_17020_3	 => 0,
      :room_type_17020_4	 => 0,
      :room_type_17020_9	 => 0,
      :room_type_17025_1	 => 0,
      :room_type_17025_2	 => 0,
      :room_type_17025_3	 => 0,
      :room_type_17025_4	 => 0,
      :room_type_17025_9	 => 0,
      :room_type_17030_1	 => 0,
      :room_type_17030_2	 => 0,
      :room_type_17030_3	 => 0,
      :room_type_17030_4	 => 0,
      :room_type_17030_9	 => 0,
      :room_type_17035_1	 => 0,
      :room_type_17035_2	 => 0,
      :room_type_17035_3	 => 0,
      :room_type_17035_4	 => 0,
      :room_type_17035_9	 => 0,
      :room_type_17099_1	 => 0,
      :room_type_17099_2	 => 0,
      :room_type_17099_3	 => 0,
      :room_type_17099_4	 => 0,
      :room_type_17099_9	 => 0,
      :biru_age_0005_1	 => 0,
      :biru_age_0005_2	 => 0,
      :biru_age_0005_3	 => 0,
      :biru_age_0005_4	 => 0,
      :biru_age_0005_9	 => 0,
      :biru_age_0610_1	 => 0,
      :biru_age_0610_2	 => 0,
      :biru_age_0610_3	 => 0,
      :biru_age_0610_4	 => 0,
      :biru_age_0610_9	 => 0,
      :biru_age_1115_1	 => 0,
      :biru_age_1115_2	 => 0,
      :biru_age_1115_3	 => 0,
      :biru_age_1115_4	 => 0,
      :biru_age_1115_9	 => 0,
      :biru_age_1620_1	 => 0,
      :biru_age_1620_2	 => 0,
      :biru_age_1620_3	 => 0,
      :biru_age_1620_4	 => 0,
      :biru_age_1620_9	 => 0,
      :biru_age_2125_1	 => 0,
      :biru_age_2125_2	 => 0,
      :biru_age_2125_3	 => 0,
      :biru_age_2125_4	 => 0,
      :biru_age_2125_9	 => 0,
      :biru_age_2630_1	 => 0,
      :biru_age_2630_2	 => 0,
      :biru_age_2630_3	 => 0,
      :biru_age_2630_4	 => 0,
      :biru_age_2630_9	 => 0,
      :biru_age_3135_1	 => 0,
      :biru_age_3135_2	 => 0,
      :biru_age_3135_3	 => 0,
      :biru_age_3135_4	 => 0,
      :biru_age_3135_9	 => 0,
      :biru_age_9999_1	 => 0,
      :biru_age_9999_2	 => 0,
      :biru_age_9999_3	 => 0,
      :biru_age_9999_4	 => 0,
      :biru_age_9999_9	 => 0,
    }

    
    data_list.each do |data_hash|
      
      if data_hash[:group_name] == '00支店'
        # 支店データを設定
        if data_hash[:shop_name] == '東武支店'
          data_hash.keys.each do |key|
            if key != :shop_code and key != :shop_name and key != :group_name and key != :url
              data_hash[key] = toubu_hash[key]
            end
          end
          
          # ここでやっていること↑
          # data_hash[:building_cnt] = toubu_building_cnt
          # data_hash[:room_cnt] = toubu_room_cnt
           
        elsif data_hash[:shop_name] == 'さいたま支店'
          data_hash.keys.each do |key|
            if key != :shop_code and key != :shop_name and key != :group_name and key != :url
              data_hash[key] = saitama_hash[key]
            end
          end

        elsif data_hash[:shop_name] == '千葉支店'
          data_hash.keys.each do |key|
            if key != :shop_code and key != :shop_name and key != :group_name and key != :url
              data_hash[key] = chiba_hash[key]
            end
          end
        end
        
      elsif data_hash[:group_name] == '99その他' && data_hash[:shop_name] == 'ビル全体'
        
          # data_hash[:building_cnt] = toubu_building_cnt + saitama_building_cnt + chiba_building_cnt + etc_building_cnt
          # data_hash[:room_cnt] = toubu_room_cnt + saitama_room_cnt + chiba_room_cnt + etc_room_cnt

          data_hash.keys.each do |key|
            if key != :shop_code and key != :shop_name and key != :group_name and key != :url
              data_hash[key] = toubu_hash[key].to_i + saitama_hash[key].to_i + chiba_hash[key].to_i
            end
          end
        
      else
        
        # 営業所のデータを取得
        grid_rec = grid_data[data_hash[:shop_code]]
        if grid_rec

          data_hash.keys.each do |key|
            if key != :shop_code and key != :shop_name and key != :group_name and key != :url
              data_hash[key] = grid_rec[key]
            end
          end
          
          # ここでやっていること↑
          # data_hash[:building_cnt] = grid_rec[:building_cnt]
          # data_hash[:room_cnt] = grid_rec[:room_cnt]
          # data_hash[:biru_type_mn_cnt] = grid_rec[:biru_type_mn_cnt]
          # data_hash[:biru_type_bm_cnt] = grid_rec[:biru_type_bm_cnt]
          # data_hash[:biru_type_ap_cnt] = grid_rec[:biru_type_ap_cnt]
          # data_hash[:biru_type_kdt_cnt] = grid_rec[:biru_type_kdt_cnt]
          # data_hash[:biru_type_etc_cnt] = grid_rec[:biru_type_etc_cnt]


          if data_hash[:group_name] == '01東武'

            toubu_hash.keys.each do |key|
              if key != :shop_code and key != :shop_name and key != :group_name and key != :url
                toubu_hash[key] = toubu_hash[key] + grid_rec[key]
              end
            end

            
          elsif data_hash[:group_name] == '02さいたま'
            saitama_hash.keys.each do |key|
              if key != :shop_code and key != :shop_name and key != :group_name and key != :url
                saitama_hash[key] = saitama_hash[key] + grid_rec[key]
              end
            end

          elsif data_hash[:group_name] == '03千葉'
            chiba_hash.keys.each do |key|
              if key != :shop_code and key != :shop_name and key != :group_name and key != :url
                chiba_hash[key] = chiba_hash[key] + grid_rec[key]
              end
            end
            
          else

            etc_hash.keys.each do |key|
              if key != :shop_code and key != :shop_name and key != :group_name and key != :url
                etc_hash[key] = etc_hash[key] + grid_rec[key]
              end
            end
            
          end
          
        end
        
      end
      
    end
      
    gon.data_list = data_list
    
  end

  def map
    
    ##########################
    # 取得する営業所の絞り込み
    ##########################
    @shop_where = ""
    if params[:stcd]
      params[:stcd].split(",").each do |store_code|
        # 数字になり得るのなら引数として採用
        if store_code.strip =~ /\A-?\d+(.\d+)?\Z/
          
          unless @shop_where.length == 0
            @shop_where = @shop_where + ","
          end
        
          @shop_where = @shop_where + store_code
          
        end
        
      end
    end
      
    
    ##############################
    # 物件・営業所・貸主と紐付きの取得
    ##############################
    buildings = []
    shops = []
    owners = []
    trusts = []
    owner_to_buildings = {}
    building_to_owners = {}
    
    # 登録済みチェック用
    check_building = {} # 管理方式が異なり同じ建物が2度くることが無いとはいえないので念のため一意になるようチェック
    check_owner = {}
    check_shop = {}
    check_trust = {}
          
    grid_data = []
    
    ActiveRecord::Base.connection.select_all(get_biru_list_sql(@shop_where)).each do |rec|
      
      ####################
      # 地図で使う物件情報
      ####################
      biru = {
        :id=>rec["building_id"],
        :name=>rec["building_name"],
        :latitude=>rec["building_latitude"], 
        :longitude=>rec["building_longitude"], 
        :build_type_icon=>rec["buid_type_icon"],
        :room_cnt=>rec["room_cnt"],
        :free_cnt=>rec["free_cnt"],
        :biru_age=>rec["biru_age"],
        :manage_type_icon=>rec["manage_type_icon"],
        :shop_code=>rec["shop_code"],
        
        :trust_mente_junkai_seisou=>rec["trust_mente_junkai_seisou"],
        :trust_mente_kyusui_setubi=>rec["trust_mente_kyusui_setubi"], 
        :trust_mente_tyosui_seisou=>rec["trust_mente_tyosui_seisou"],
        :trust_mente_elevator_hosyu=>rec["trust_mente_elevator_hosyu"],
        :trust_mente_bouhan_camera=>rec["trust_mente_bouhan_camera"],
        
      }
      
      
      unless check_building[biru[:id]] 
        buildings.push(biru)
        check_building[biru[:id]] = true
      end
      
      # 営業所の登録
      unless check_shop[rec["shop_id"]]
        shop = {:id=>rec["shop_id"], :name=>rec["shop_name"], :latitude=>rec["shop_latitude"], :longitude=>rec["shop_longitude"], :icon =>rec["shop_icon"]}
        shops.push(shop)
        check_shop[shop[:id]] = true
      end
      
      # 貸主の登録
      owner = {:id=>rec["owner_id"], :name=>rec["owner_name"], :latitude=>rec["owner_latitude"], :longitude=>rec["owner_longitude"]}
      unless check_owner[owner[:id]]
        owners.push(owner)
        check_owner[owner[:id]] = true
      end
      
      # 貸主に対する紐付きの作成
      owner_to_buildings[owner[:id]] = [] unless owner_to_buildings[owner[:id]]
      owner_to_buildings[owner[:id]] << biru

      # 建物に紐づく貸主一覧を作成する。※本来建物に対するオーナーは１人だが、念のため複数オーナーも対応する。
      building_to_owners[biru[:id]] = [] unless building_to_owners[biru[:id]]
      building_to_owners[biru[:id]] << owner
      
      # 委託の登録
      trust = {:id=>rec["trust_id"], :owner_id=>owner[:id], :building_id=>biru[:id]}
      unless check_trust[trust[:id]] 
        trusts.push(trust)
        check_trust[trust[:id]] = true
      end
      
      ########################
      # 一覧表で使う情報
      ########################
      row_data = {}
      row_data[:trsut_id] = rec["trust_id"]
      row_data[:building_id] = rec["building_id"]
      row_data[:shop_name] = rec["shop_name"]
      row_data[:building_code] = rec["building_code"]
      row_data[:building_name] = rec["building_name"]
      row_data[:building_address] = rec["building_address"]
      row_data[:room_cnt] = rec["room_cnt"]
      row_data[:owner_code] = rec["owner_code"]
      row_data[:owner_address] = rec["owner_address"]
      row_data[:owner_name] = rec["owner_name"]
      
      row_data[:build_type_name] = rec["build_type_name"]
      row_data[:manage_type_name] = rec["manage_type_name"]

      row_data[:free_par] = "%.1f"%(rec["free_cnt"].to_f / rec["room_cnt"].to_f * 100).to_f unless rec["room_cnt"] == 0

      row_data[:free_cnt] = rec["free_cnt"]
      row_data[:biru_age] = rec["biru_age"]
      
      row_data[:trust_mente_junkai_seisou] = rec["trust_mente_junkai_seisou"]
      row_data[:trust_mente_kyusui_setubi] = rec["trust_mente_kyusui_setubi"]
      row_data[:trust_mente_tyosui_seisou] = rec["trust_mente_tyosui_seisou"]
      row_data[:trust_mente_elevator_hosyu] = rec["trust_mente_elevator_hosyu"]
      row_data[:trust_mente_bouhan_camera] = rec["trust_mente_bouhan_camera"]

      grid_data.push(row_data)
    end

    gon.buildings = buildings
    gon.owners = owners 
    gon.trusts = trusts
    gon.shops = shops
    gon.owner_to_buildings = owner_to_buildings
    gon.building_to_owners = building_to_owners
    
    gon.grid_data = grid_data

    # 一覧のコンボボックス
    @combo_shop = jqgrid_combo_shop
    @combo_build_type = jqgrid_combo_build_type
    @combo_manage_type = jqgrid_combo_manage_type
    
  end
  
  
  # ファイル出力（CSV出力）
  def csv_out
    str = ""
    
    # params[:data].keys.each do |key|
    #   str = str + params[:data][key].values.join(',')
    #   str = str + "\n"
    # end

    # csvデータ作成
    data = ActiveRecord::Base.connection.select_all(get_biru_list_sql(params[:shop_list], true))
    
    keys = [ "shop_name", "building_code", "building_name", "manage_type_name", "build_type_name", "room_name", "room_status"]
    
    data.each do |row|
      keys.each do |key|
        str = str + row[key].to_s + ","
      end
      str = str + "\n"
    end
    
    send_data str, :filename=>'output_room.csv'
  end
  
  
  
private
  # 自社管理（B以上）の物件を戸数単位で営業所別に表示する
  
  # room_flg : 部屋単位の出力をする
  def get_biru_list_sql(shop_list, room_flg = false)
    
    strSql = ""
    strSql = strSql + "select "
    strSql = strSql + " a.id as building_id "
    strSql = strSql + ",a.code as building_code "
    strSql = strSql + ",a.name as building_name "
    strSql = strSql + ",a.address as building_address "
    strSql = strSql + ",a.latitude as building_latitude "
    strSql = strSql + ",a.longitude as building_longitude "
    
    strSql = strSql + ",c.id as shop_id "
    strSql = strSql + ",c.code as shop_code "
    strSql = strSql + ",c.name as shop_name "
    strSql = strSql + ",c.address as shop_address "
    strSql = strSql + ",c.latitude as shop_latitude "
    strSql = strSql + ",c.longitude as shop_longitude "
    strSql = strSql + ",c.icon as shop_icon "
    
    strSql = strSql + ",f.id as owner_id "
    strSql = strSql + ",f.code as owner_code "
    strSql = strSql + ",f.name as owner_name "
    strSql = strSql + ",f.address as owner_address "
    strSql = strSql + ",f.latitude as owner_latitude "
    strSql = strSql + ",f.longitude as owner_longitude "
    
    strSql = strSql + ",d.id as trust_id "
    strSql = strSql + ",e.name as manage_type_name "
    strSql = strSql + ",e.icon as manage_type_icon "
    
    strSql = strSql + ",g.code as build_type_code "
    strSql = strSql + ",g.name as build_type_name "
    strSql = strSql + ",g.icon as buid_type_icon "
    
    # strSql = strSql + ",count(b.id) as room_cnt "
    # strSql = strSql + ",SUM(CASE free_state when 't' then 1 else 0 end) as free_cnt "
    strSql = strSql + ",a.kanri_room_num as room_cnt "
    strSql = strSql + ",a.free_num as free_cnt "
    strSql = strSql + ",a.biru_age as biru_age "
    
    strSql = strSql + ",MAX(case h.code when '3' then 1 else 0 end ) trust_mente_junkai_seisou "
    strSql = strSql + ",MAX(case h.code when '15' then 1 else 0 end ) trust_mente_kyusui_setubi "
    strSql = strSql + ",MAX(case h.code when '25' then 1 else 0 end ) trust_mente_tyosui_seisou "
    strSql = strSql + ",MAX(case h.code when '45' then 1 else 0 end ) trust_mente_elevator_hosyu "
    strSql = strSql + ",MAX(case h.code when '48' then 1 else 0 end ) trust_mente_bouhan_camera "

    strSql = strSql + ",SUM(case j.code when '10' then 1 else 0 end ) room_status_unrecognized "
    strSql = strSql + ",SUM(case j.code when '20' then 1 else 0 end ) room_status_owner_stop "
    strSql = strSql + ",SUM(case j.code when '30' then 1 else 0 end ) room_status_space "
    strSql = strSql + ",SUM(case j.code when '40' then 1 else 0 end ) room_status_occupancy "
    strSql = strSql + ",SUM(case j.code when '50' then 1 else 0 end ) room_status_etc "
    
    if room_flg then
      strSql = strSql + ",b.name as room_name "
      strSql = strSql + ",k.code as room_type_code "
      strSql = strSql + ",k.name as room_type_name "
      strSql = strSql + ",l.code as room_layout_code "
      strSql = strSql + ",l.name as room_layout_name "
    end

    strSql = strSql + "from buildings a "
    strSql = strSql + "inner join rooms b on a.id = b.building_id "
    strSql = strSql + "inner join shops c on c.id = a.shop_id "
    strSql = strSql + "inner join trusts d on a.id = d.building_id "
    strSql = strSql + "inner join manage_types e on e.id = b.manage_type_id  "
    strSql = strSql + "inner join owners f on d.owner_id = f.id "
    strSql = strSql + "inner join build_types g on a.build_type_id = g.id "
    strSql = strSql + "inner join room_statuses j on b.room_status_id = j.id "
    strSql = strSql + "inner join room_types k on b.room_type_id = k.id "
    strSql = strSql + "inner join room_layouts l on b.room_layout_id = l.id "
    
    strSql = strSql + "left outer join (select * from trust_maintenances where delete_flg = 'f' ) h on h.trust_id = d.id "
    strSql = strSql + "where 1 = 1  "
    strSql = strSql + "and c.code in ( " + shop_list + ") " if shop_list.length > 0
    strSql = strSql + "and a.delete_flg = 'f' "
    strSql = strSql + "and b.delete_flg = 'f' "
    strSql = strSql + "and d.delete_flg = 'f' "
    strSql = strSql + "and e.code in (3,4,5,6,9, 7,8,10) "
    strSql = strSql + "group by a.id "
    strSql = strSql + ",a.code"
    strSql = strSql + ",a.name"
    strSql = strSql + ",a.address"
    strSql = strSql + ",a.latitude"
    strSql = strSql + ",a.longitude"
    strSql = strSql + ",c.id"
    strSql = strSql + ",c.code"
    strSql = strSql + ",c.name"
    strSql = strSql + ",c.address"
    strSql = strSql + ",c.latitude"
    strSql = strSql + ",c.longitude"
    strSql = strSql + ",c.icon"
    strSql = strSql + ",d.id "
    strSql = strSql + ",e.name "
    strSql = strSql + ",e.icon "
    strSql = strSql + ",f.id "
    strSql = strSql + ",f.code "
    strSql = strSql + ",f.name "
    strSql = strSql + ",f.address "
    strSql = strSql + ",f.latitude "
    strSql = strSql + ",f.longitude "
    strSql = strSql + " ,g.name"
    strSql = strSql + " ,g.code"
    strSql = strSql + " ,g.icon"
    strSql = strSql + " ,a.kanri_room_num"
    strSql = strSql + " ,a.free_num"
    strSql = strSql + " ,a.biru_age"
    
    if room_flg then
      strSql = strSql + ",b.name "
      strSql = strSql + ",k.code "
      strSql = strSql + ",k.name "
      strSql = strSql + ",l.code "
      strSql = strSql + ",l.name "
    end
    
    strSql = strSql + " "
    
    return strSql
  end
  
  def get_shop_list_sql
    strSql = ""
    strSql = strSql + "SELECT "
    strSql = strSql + "shop_id "
    strSql = strSql + ",shop_name "
    strSql = strSql + ",shop_code "
    strSql = strSql + ",count(*) as building_cnt "
    strSql = strSql + ",SUM(case when build_type_code = '01010' then 1 else 0 end ) as biru_type_mn_cnt "
    strSql = strSql + ",SUM(case when build_type_code = '01015' then 1 else 0 end ) as biru_type_bm_cnt "
    strSql = strSql + ",SUM(case when build_type_code = '01020' then 1 else 0 end ) as biru_type_ap_cnt "
    strSql = strSql + ",SUM(case when build_type_code = '01025' then 1 else 0 end ) as biru_type_kdt_cnt "
    strSql = strSql + ",SUM(case when build_type_code in ('01010', '01015', '01020', '01025' ) then 0 else 1 end ) as biru_type_etc_cnt "
    strSql = strSql + ",SUM( trust_mente_junkai_seisou ) as trust_mente_junkai_seisou_cnt "
    strSql = strSql + ",SUM( trust_mente_kyusui_setubi ) as trust_mente_kyusui_setubi_cnt "
    strSql = strSql + ",SUM( trust_mente_tyosui_seisou ) as trust_mente_tyosui_seisou_cnt "
    strSql = strSql + ",SUM( trust_mente_elevator_hosyu ) as trust_mente_elevator_hosyu_cnt "
    strSql = strSql + ",SUM( trust_mente_bouhan_camera ) as trust_mente_bouhan_camera_cnt "
    strSql = strSql + ",sum(room_cnt) as shop_room_cnt "
    strSql = strSql + ",SUM(room_status_unrecognized) as room_status_unrecognized_sum "
    strSql = strSql + ",SUM(room_status_owner_stop) as room_status_owner_stop_sum "
    strSql = strSql + ",SUM(room_status_space) as room_status_space_sum "
    strSql = strSql + ",SUM(room_status_occupancy) as room_status_occupancy_sum "
    strSql = strSql + ",SUM(room_status_etc) as room_status_etc_sum "
    
    strSql = strSql + "FROM (" + get_biru_list_sql('') + ") X "
    strSql = strSql + "GROUP BY shop_id, shop_name, shop_code "
    
    return strSql
  end
  
end
