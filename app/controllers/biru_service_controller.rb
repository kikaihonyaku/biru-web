#-*- encoding:utf-8 -*- 

# 建物管理を表示するコントローラ
class BiruServiceController < ApplicationController
  def index
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
        group_name = "99不明"
        arr_unknown.push(shop.code)
      end
      
      data_list.push({
        :shop_code => shop.code, :shop_name => shop.name, :group_name => group_name ,:url => 'map?stcd=' + shop.code, :building_cnt => 0 ,:room_cnt => 0
      })
    end
    
    data_list.push({ :shop_code => '100', :shop_name => '東武支店', :group_name => '00支店' ,:url => 'map?stcd=' + arr_tobu.join(','), :building_cnt => 0 ,:room_cnt => 0})
    data_list.push({ :shop_code => '200', :shop_name => 'さいたま支店', :group_name => '00支店' ,:url => 'map?stcd=' + arr_saitama.join(','), :building_cnt => 0 ,:room_cnt => 0})
    data_list.push({ :shop_code => '300', :shop_name => '千葉支店', :group_name => '00支店' ,:url => 'map?stcd=' + arr_chiba.join(','), :building_cnt => 0 ,:room_cnt => 0})

    ##############################
    # 営業所データをハッシュに格納
    ##############################
    grid_data = {}
    ActiveRecord::Base.connection.select_all(get_shop_list_sql).each do |rec|
      unless grid_data[rec['shop_code']]
        grid_data[rec['shop_code']] = {:shop_code => rec['shop_code'], :building_cnt => rec['building_cnt'], :room_cnt => rec['shop_room_cnt'] }
      end
    end
    
    ##############################
    # 営業所の枠に取得した値を格納
    ##############################
    
    toubu_building_cnt = 0
    toubu_room_cnt = 0
    
    saitama_building_cnt = 0
    saitama_room_cnt = 0
    
    chiba_building_cnt = 0
    chiba_room_cnt = 0
    
    data_list.each do |data_hash|
      
      if data_hash[:group_name] == '00支店'
        # 支店データを設定
        if data_hash[:shop_name] == '東武支店'
          data_hash[:building_cnt] = toubu_building_cnt
          data_hash[:room_cnt] = toubu_room_cnt
           
        elsif data_hash[:shop_name] == 'さいたま支店'
          data_hash[:building_cnt] = saitama_building_cnt
          data_hash[:room_cnt] = saitama_room_cnt
          
        elsif data_hash[:shop_name] == '千葉支店'
          data_hash[:building_cnt] = chiba_building_cnt
          data_hash[:room_cnt] = chiba_room_cnt
        end
        
      else
        
        # 営業所のデータを取得
        grid_rec = grid_data[data_hash[:shop_code]]
        if grid_rec
          data_hash[:building_cnt] = grid_rec[:building_cnt]
          data_hash[:room_cnt] = grid_rec[:room_cnt]
          
          if data_hash[:group_name] == '01東武'
            toubu_building_cnt = toubu_building_cnt + grid_rec[:building_cnt]
            toubu_room_cnt = toubu_room_cnt + grid_rec[:room_cnt]
            
          elsif data_hash[:group_name] == '02さいたま'
            saitama_building_cnt = saitama_building_cnt + grid_rec[:building_cnt]
            saitama_room_cnt = saitama_room_cnt + grid_rec[:room_cnt]

          elsif data_hash[:group_name] == '03千葉'
            chiba_building_cnt = chiba_building_cnt + grid_rec[:building_cnt]
            chiba_room_cnt = chiba_room_cnt + grid_rec[:room_cnt]

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
    
    ActiveRecord::Base.connection.select_all(get_biru_list_sql(shop_where)).each do |rec|
      
      # 物件の登録
      biru = {:id=>rec["building_id"], :name=>rec["building_name"], :latitude=>rec["building_latitude"], :longitude=>rec["building_longitude"]}
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
      
      # 表に表示する為の登録
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
      grid_data.push(row_data)
    end

    gon.buildings = buildings
    gon.owners = owners 
    gon.trusts = trusts
    gon.shops = shops
    gon.owner_to_buildings = owner_to_buildings
    gon.building_to_owners = building_to_owners
    
    gon.grid_data = grid_data
    
  end
  
private
  # 自社管理（B以上）の物件を戸数単位で営業所別に表示する
  def get_biru_list_sql(shop_list)
    
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
    strSql = strSql + ",e.name as manage_name "
    
    strSql = strSql + ",count(b.id) as room_cnt "
    strSql = strSql + "from buildings a "
    strSql = strSql + "inner join rooms b on a.id = b.building_id "
    strSql = strSql + "inner join shops c on c.id = a.shop_id "
    strSql = strSql + "inner join trusts d on a.id = d.building_id "
    strSql = strSql + "inner join manage_types e on e.id = b.manage_type_id  "
    strSql = strSql + "inner join owners f on d.owner_id = f.id "
    strSql = strSql + "where 1 = 1  "
    strSql = strSql + "and c.code in ( " + shop_list + ") " if shop_list.length > 0
    strSql = strSql + "and not a.delete_flg "
    strSql = strSql + "and not b.delete_flg  "
    strSql = strSql + "and not d.delete_flg "
    strSql = strSql + "and e.code in (3,4,5,6,9, 7,8,10) "
    strSql = strSql + "group by a.id, a.code, a.name, e.name, c.id, c.code, c.name "
    strSql = strSql + "     "
    
    return strSql
  end
  
  def get_shop_list_sql
    strSql = ""
    strSql = strSql + "SELECT "
    strSql = strSql + "shop_id "
    strSql = strSql + ",shop_name "
    strSql = strSql + ",shop_code "
    strSql = strSql + ",count(*) as building_cnt "
    strSql = strSql + ",sum(room_cnt) as shop_room_cnt "
    strSql = strSql + "FROM (" + get_biru_list_sql('') + ") X "
    strSql = strSql + "GROUP BY shop_id, shop_name, shop_code "
    
    return strSql
  end
  
end
