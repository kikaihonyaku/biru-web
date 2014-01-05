# -*- coding:utf-8 -*-

require 'csv'
require 'kconv'

#------------------------------
# 路線マスタ／駅マスタを登録します。
#------------------------------
def init_station
  
end

#--------------------------
# 営業所マスタを登録します。
#--------------------------
def init_shop

  show_arr = []

  # 東武支店
  show_arr.push({:code=>3, :name=>'草加営業所', :address=>'埼玉県草加市氷川町2131番地3', :area_id=>1, :group_id=>1, :tel=>'0120-278-342', :tel2=>'xxx-xxxx-xxxx', :holiday=>'水曜'})
  show_arr.push({:code=>11, :name=>'草加新田営業所', :address=>'埼玉県草加市金明町276', :area_id=>1, :group_id=>1, :tel=>'0120-702-728', :tel2=>'xxx-xxxx-xxxx', :holiday=>'火曜'})
  show_arr.push({:code=>16, :name=>'北千住営業所', :address=>'東京都足立区千住3-1 石黒ビル2F', :area_id=>1, :group_id=>1, :tel=>'0120-956-776', :tel2=>'xxx-xxxx-xxxx', :holiday=>'水曜'})
  show_arr.push({:code=>1, :name=>'南越谷営業所', :address=>'埼玉県越谷市南越谷1-20-17　中央ビル管理本社ビル内1F', :area_id=>2, :group_id=>1, :tel=>'0120-754-215', :tel2=>'xxx-xxxx-xxxx', :holiday=>'無休'})
  show_arr.push({:code=>18, :name=>'越谷営業所', :address=>'埼玉県越谷市赤山本町2-14', :area_id=>2, :group_id=>1, :tel=>'0120-948-909', :tel2=>'xxx-xxxx-xxxx', :holiday=>'水曜'})
  show_arr.push({:code=>8, :name=>'北越谷営業所', :address=>'埼玉県越谷市大沢3-19-17', :area_id=>3, :group_id=>1, :tel=>'0120-304-137', :tel2=>'xxx-xxxx-xxxx', :holiday=>'水曜'})
  show_arr.push({:code=>7, :name=>'春日部営業所', :address=>'埼玉県春日部市中央1-2-5', :area_id=>3, :group_id=>1, :tel=>'0120-675-488', :tel2=>'xxx-xxxx-xxxx', :holiday=>'火曜'})
  show_arr.push({:code=>21, :name=>'せんげん台営業所', :address=>'埼玉県越谷市千間台東1-8-1', :area_id=>3, :group_id=>1, :tel=>'0120-929-979', :tel2=>'xxx-xxxx-xxxx', :holiday=>'火・水曜'})

  # さいたま支店
  show_arr.push({:code=>2, :name=>'戸田営業所', :address=>'埼玉県戸田市大字新曽353-6', :area_id=>11, :group_id=>2, :tel=>'0120-654-021', :tel2=>'xxx-xxxx-xxxx', :holiday=>'火曜'})
  show_arr.push({:code=>5, :name=>'武蔵浦和営業所', :address=>'埼玉県さいたま市南区別所7-9-5', :area_id=>12, :group_id=>2, :tel=>'0120-634-315', :tel2=>'xxx-xxxx-xxxx', :holiday=>'水曜'})
  show_arr.push({:code=>15, :name=>'川口営業所', :address=>'埼玉県川口市川口1-1-1 キュポ・ラ専門店1F', :area_id=>13, :group_id=>2, :tel=>'0120-163-366', :tel2=>'xxx-xxxx-xxxx', :holiday=>'水曜'})
  show_arr.push({:code=>17, :name=>'浦和営業所', :address=>'埼玉県さいたま市浦和区東仲町11-23 3F', :area_id=>14, :group_id=>2, :tel=>'0120-953-833', :tel2=>'xxx-xxxx-xxxx', :holiday=>'火・水曜'})
  show_arr.push({:code=>13, :name=>'与野営業所', :address=>'埼玉県さいたま市浦和区上木崎1丁目8-10', :area_id=>15, :group_id=>2, :tel=>'0120-234-495', :tel2=>'xxx-xxxx-xxxx', :holiday=>'水曜'})
  show_arr.push({:code=>10, :name=>'東浦和営業所', :address=>'埼玉県さいたま市緑区東浦和1-14-7', :area_id=>16, :group_id=>2, :tel=>'0120-817-455', :tel2=>'xxx-xxxx-xxxx', :holiday=>'水曜'})
  show_arr.push({:code=>6, :name=>'東川口営業所', :address=>'埼玉県川口市東川口2丁目3-35 サクセスＩＭ1F', :area_id=>17, :group_id=>2, :tel=>'0120-643-552', :tel2=>'xxx-xxxx-xxxx', :holiday=>'火曜'})
  show_arr.push({:code=>14, :name=>'戸塚安行営業所', :address=>'埼玉県川口市長蔵1-16-19 クレアーレ1F', :area_id=>18, :group_id=>2, :tel=>'0120-577-933', :tel2=>'xxx-xxxx-xxxx', :holiday=>'火曜'})

  # 千葉支店
  show_arr.push({:code=>19, :name=>'松戸営業所', :address=>'千葉県松戸市本町18-6 壱番館ビル3Ｆ', :area_id=>21, :group_id=>3, :tel=>'0120-981-703', :tel2=>'xxx-xxxx-xxxx', :holiday=>'火・水曜'})
  show_arr.push({:code=>4, :name=>'北松戸営業所', :address=>'千葉県松戸市上本郷900－2 中央第10北松戸ビル1Ｆ', :area_id=>22, :group_id=>3, :tel=>'0120-518-655', :tel2=>'xxx-xxxx-xxxx', :holiday=>'火・水曜'})
  show_arr.push({:code=>12, :name=>'南流山営業所', :address=>'千葉県流山市南流山1-1-14', :area_id=>23, :group_id=>3, :tel=>'0120-477-512', :tel2=>'xxx-xxxx-xxxx', :holiday=>'火曜'})
  show_arr.push({:code=>9, :name=>'柏営業所', :address=>'千葉県柏市あけぼの1-1-2', :area_id=>24, :group_id=>3, :tel=>'0120-708-251', :tel2=>'xxx-xxxx-xxxx', :holiday=>'火・水曜'})

  # 法人課
  show_arr.push({:code=>91, :name=>'法人課', :address=>'埼玉県越谷市南越谷４丁目９−６', :area_id=>30, :group_id=>4, :tel=>'0120-922-597', :tel2=>'xxx-xxxx-xxxx', :holiday=>'無休'})

  # ダミー　支店など用
  #show_arr.push({:code=>99, :name=>'ダミー', :address=>'', :area_id=>90, :group_id=>9})

  show_arr.each do |obj|
    p obj[:name]
    shop =  Shop.find_or_create_by_code(obj[:code])
    shop.code = obj[:code]
    shop.name = obj[:name]
    shop.address = obj[:address]
    shop.area_id = obj[:area_id]
    shop.group_id = obj[:group_id]
    shop.tel = obj[:tel]
    shop.tel2 = obj[:tel2]
    shop.holiday = obj[:holiday]

    # 支店別にアイコンを指定する
    case shop.group_id
      when 1
        shop.icon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%e5%96%b6|00FF00|000000'
      when 2
        shop.icon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%e5%96%b6|0033FF|FFFFFF'
      when 3
        shop.icon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%e5%96%b6|FFFF00|000000'
      when 4
        shop.icon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%e5%96%b6|8A2BE2|FFFFFF'
      else
    end

    # ジオコーディング
    unless shop.code == 99
      biru_geocode(shop, true)
    else
      # スキップする
      shop.gmaps = true
    end

    shop.save!
  end

end

#-------------
# 物件種別の登録
#-------------
def init_biru_type
  type_arr = []

  type_arr.push({:name=>'マンション', :code=>'01010', :icon=>'/assets/marker_yellow.png'})
  type_arr.push({:name=>'分譲マンション', :code=>'01015', :icon=>'/assets/marker_purple.png'})
  type_arr.push({:name=>'アパート', :code=>'01020', :icon=>'/assets/marker_blue.png'})
  type_arr.push({:name=>'一戸建貸家', :code=>'01025', :icon=>'/assets/marker_red.png'})
  type_arr.push({:name=>'テラスハウス', :code=>'01030', :icon=>'/assets/marker_orange.png'})
  type_arr.push({:name=>'メゾネット', :code=>'01035', :icon=>'/assets/marker_green.png'})
  type_arr.push({:name=>'店舗', :code=>'01040', :icon=>'/assets/marker_gray.png'})
  type_arr.push({:name=>'店舗付住宅', :code=>'01045', :icon=>'/assets/marker_gray.png'})
  type_arr.push({:name=>'事務所', :code=>'01050', :icon=>'/assets/marker_gray.png'})
  type_arr.push({:name=>'工場', :code=>'01055', :icon=>'/assets/marker_gray.png'})
  type_arr.push({:name=>'倉庫', :code=>'01060', :icon=>'/assets/marker_gray.png'})
  type_arr.push({:name=>'倉庫事務所', :code=>'01065', :icon=>'/assets/marker_gray.png'})
  type_arr.push({:name=>'工場倉庫', :code=>'01070', :icon=>'/assets/marker_gray.png'})
  type_arr.push({:name=>'定期借地権', :code=>'01085', :icon=>'/assets/marker_gray.png'})
  type_arr.push({:name=>'その他', :code=>'01998', :icon=>'/assets/marker_white.png'})

  type_arr.each do |obj|
    biru_type = BuildType.find_or_create_by_code(obj[:code])
    biru_type.code = obj[:code]
    biru_type.name = obj[:name]
    biru_type.icon = obj[:icon]
    biru_type.save!
    p biru_type
  end
end

# 管理方式の登録
def init_manage_type

  manage_arr = []

  manage_arr.push(:name=>'一般', :code=>'1', :icon=>'/assets/marker_yellow.png', :line_color=>'yellow')
  manage_arr.push(:name=>'A管理', :code=>'2', :icon=>'/assets/marker_red.png', :line_color=>'red')
  manage_arr.push(:name=>'B管理', :code=>'3', :icon=>'/assets/marker_blue.png', :line_color=>'darkblue')
  manage_arr.push(:name=>'C管理', :code=>'4', :icon=>'/assets/marker_gray.png', :line_color=>'gray')
  manage_arr.push(:name=>'D管理', :code=>'6', :icon=>'/assets/marker_purple.png', :line_color=>'purple')
  manage_arr.push(:name=>'総務君', :code=>'7', :icon=>'/assets/marker_green.png', :line_color=>'green')
  manage_arr.push(:name=>'特優賃', :code=>'8', :icon=>'/assets/marker_gray.png', :line_color=>'gray')
  manage_arr.push(:name=>'定期借地', :code=>'9', :icon=>'/assets/marker_gray.png', :line_color=>'gray')
  manage_arr.push(:name=>'業務君', :code=>'10', :icon=>'/assets/marker_orange.png', :line_color=>'orange')
  manage_arr.push(:name=>'管理外', :code=>'99', :icon=>'/assets/marker_white.png', :line_color=>'black')

  manage_arr.each do |obj|
    manage_type = ManageType.find_or_create_by_code(obj[:code])
    manage_type.code = obj[:code]
    manage_type.name = obj[:name]
    manage_type.icon = obj[:icon]
    manage_type.line_color = obj[:line_color]
    manage_type.save!
    p manage_type
  end

end

# 部屋種別の登録
def init_room_type
    type_arr = []

    type_arr.push({:name=>'マンション', :code=>'17010'})
    type_arr.push({:name=>'分譲賃貸マンション', :code=>'17015'})
    type_arr.push({:name=>'アパート', :code=>'17020'})
    type_arr.push({:name=>'一戸建貸家', :code=>'17025'})
    type_arr.push({:name=>'テラスハウス', :code=>'17030'})
    type_arr.push({:name=>'メゾネット', :code=>'17035'})
    type_arr.push({:name=>'店舗', :code=>'17040'})
    type_arr.push({:name=>'店舗付住宅', :code=>'17045'})
    type_arr.push({:name=>'事務所', :code=>'17050'})
    type_arr.push({:name=>'工場', :code=>'17055'})
    type_arr.push({:name=>'倉庫', :code=>'17060'})
    type_arr.push({:name=>'工場倉庫', :code=>'17065'})

    type_arr.each do |obj|
      room_type = RoomType.find_or_create_by_code(obj[:code])
      room_type.code = obj[:code]
      room_type.name = obj[:name]
      room_type.save!
      p room_type
    end
end


# 間取りの登録
def init_room_layout
  layout_arr = []
  layout_arr.push({:name=>'１Ｒ', :code=>'18100'})
  layout_arr.push({:name=>'１Ｋ', :code=>'18105'})
  layout_arr.push({:name=>'１ＤＫ', :code=>'18110'})
  layout_arr.push({:name=>'１ＬＤＫ', :code=>'18120'})
  layout_arr.push({:name=>'１ＳＬＤＫ', :code=>'18125'})
  layout_arr.push({:name=>'２Ｋ', :code=>'18200'})
  layout_arr.push({:name=>'２ＤＫ', :code=>'18205'})
  layout_arr.push({:name=>'２ＳＤＫ', :code=>'18210'})
  layout_arr.push({:name=>'２ＬＤＫ', :code=>'18215'})
  layout_arr.push({:name=>'２ＳＬＤＫ', :code=>'18220'})
  layout_arr.push({:name=>'３Ｋ', :code=>'18300'})
  layout_arr.push({:name=>'３ＤＫ', :code=>'18305'})
  layout_arr.push({:name=>'３ＳＤＫ', :code=>'18310'})
  layout_arr.push({:name=>'３ＳＫ', :code=>'18311'})
  layout_arr.push({:name=>'３ＬＤＫ', :code=>'18315'})
  layout_arr.push({:name=>'３ＳＬＤＫ', :code=>'18320'})
  layout_arr.push({:name=>'４Ｋ', :code=>'18400'})
  layout_arr.push({:name=>'４ＤＫ', :code=>'18405'})
  layout_arr.push({:name=>'４ＳＤＫ', :code=>'18410'})
  layout_arr.push({:name=>'４ＬＤＫ', :code=>'18415'})
  layout_arr.push({:name=>'４ＳＬＤＫ', :code=>'18420'})
  layout_arr.push({:name=>'５Ｋ', :code=>'18500'})
  layout_arr.push({:name=>'５ＤＫ', :code=>'18505'})
  layout_arr.push({:name=>'５ＳＤＫ', :code=>'18510'})
  layout_arr.push({:name=>'５ＳＫ', :code=>'18511'})
  layout_arr.push({:name=>'５ＬＤＫ', :code=>'18515'})
  layout_arr.push({:name=>'５ＳＬＤＫ', :code=>'18520'})
  layout_arr.push({:name=>'６Ｋ', :code=>'18600'})
  layout_arr.push({:name=>'６ＤＫ', :code=>'18605'})
  layout_arr.push({:name=>'６ＳＤＫ', :code=>'18610'})
  layout_arr.push({:name=>'６ＬＤＫ', :code=>'18615'})
  layout_arr.push({:name=>'６ＳＬＤＫ', :code=>'18620'})
  layout_arr.push({:name=>'７ＤＫ', :code=>'18705'})
  layout_arr.push({:name=>'その他', :code=>'18998'})

  layout_arr.each do |obj|
    room_layout = RoomLayout.find_or_create_by_code(obj[:code])
    room_layout.code = obj[:code]
    room_layout.name = obj[:name]
    room_layout.save!
    p room_layout
  end

end


# 物件種別
def convert_biru_type(num)
  build_type = BuildType.find_by_code(num)
  if build_type
    return build_type.id
  else
    return nil
  end
end

# 店タイプ
def convert_shop(num)
  shop = Shop.find_by_code(num)
  if shop
    return shop.id
  else
    nil
  end

end



# geocoding
# force:強制的にgeocodingを行う。
def biru_geocode(biru, force)
  begin

    skip_flg = biru.gmaps
    skip_flg = false if force

    unless skip_flg
      gmaps_ret = Gmaps4rails.geocode(biru.address)
      biru.latitude = gmaps_ret[0][:lat]
      biru.longitude = gmaps_ret[0][:lng]
      biru.gmaps = true

#      if biru.code
#        p format("%05d",biru.code) + ':' + biru.name + ':' + biru.address
#      else
#        p format("%05d",biru.attack_code) + ':' + biru.name + ':' + biru.address
#      end
    end
  rescue
    if biru.name.nil? or biru.address.nil?
      p "エラー:geocode "
    else
      p "エラー:geocode " + biru.name + ':' + biru.address
    end

	# エラー処理
    biru.gmaps = false
    biru.delete_flg = true

  end
end

# type: 1=自社 2=他社 を初期化します
def before_imp_init(type)

  # 削除フラグをON して自社物の初期化
  if type == 1
    relation_arr = Building.unscoped.where("code is not null")
  else
    relation_arr = Building.unscoped.where("attack_code is not null")
  end

  relation_arr.each do|biru|

    # 部屋の初期化
    biru.rooms.each do |room|
      room.delete_flg = true
      room.save!
    end

    # 貸主の初期化
    biru.owners.each do |owner|
      owner.delete_flg = true
      owner.save!
    end

    # 管理委託契約CDの初期化
    biru.trusts.each do |trust|
      trust.delete_flg = true
      trust.save!
    end

    biru.delete_flg = true
    biru.save!

  end

end

# importデータの読み込み（自社）
def import_data_oneself(filename)

  # ファイル存在チェック
  unless File.exist?(filename)
    puts 'file not exist'
    return false
  end

  # imp_tablesを初期化
  ImpTable.delete_all

  # データを登録
  cnt = 0
  open(filename).each do |line|
    catch :not_header do

      if cnt == 0
        cnt = cnt + 1
        throw :not_header
      end

      cnt = cnt + 1

      row = line.split(",")

      unless row[10]
        throw :not_header
      end

      imp = ImpTable.new
      imp.siten_cd = row[0]
      imp.eigyo_order = row[1]
      imp.eigyo_cd = row[2]
      imp.eigyo_nm = row[3]
      imp.manage_type_cd = row[4]
      imp.manage_type_nm = row[5]
      imp.trust_cd = row[6]
      imp.building_cd = row[7]
      imp.building_nm = row[8]
      imp.building_type_cd = row[9]
      imp.building_address = row[10]

      imp.room_cd = row[11]
      imp.room_nm = row[12]
      imp.room_aki = row[13]
      imp.room_type_cd = row[14]
      imp.room_type_nm = row[15]
      imp.room_layout_cd = row[16]
      imp.room_layout_nm = row[17]
      imp.owner_cd = row[18]
      imp.owner_nm = row[19]
      imp.owner_kana = row[20]
      imp.owner_address = row[21]
      imp.biru_age = row[22]
      #imp.owner_tel = row[22]
      imp.save!

      if imp
        p cnt.to_s + " " + imp.building_nm + " " + imp.room_nm
      else
        p cnt.to_s
      end
    end
  end

  # 自社物の登録
  update_imp_oneself()

end

# データの更新(自社)
def update_imp_oneself()

  # 自社物の初期化(削除フラグをON)
  p "■自社情報の初期化（" + Time.now.to_s(:db) + "）"
  before_imp_init(1)

  ####################
  # 貸主の登録
  ####################
  p "■自社貸主登録（" + Time.now.to_s(:db) + "）"
  ImpTable.group(:owner_cd, :owner_nm, :owner_address ).select(:owner_cd).select(:owner_nm).select(:owner_address).each do |imp|

    owner = Owner.unscoped.find_or_create_by_code(imp.owner_cd)
    owner.code = imp.owner_cd.chomp
    owner.name = imp.owner_nm.chomp
    owner.address = imp.owner_address.chomp
    owner.delete_flg = false

    # 一時対応
    if owner.latitude
	    biru_geocode(owner, false)
    else
	    biru_geocode(owner, true)
    end

    begin
      owner.save!
      #p owner.name + " " + owner.address.chomp
    rescue => e
      #p "エラー:save " + biru.name + ':' + biru.address
      p "貸主登録エラー:save " + e.message
    end
  end

  ####################
  # 建物・部屋の登録
  ####################
  p "■自社物件登録（" + Time.now.to_s(:db) + "）"
  ImpTable.group(:eigyo_cd, :eigyo_nm, :trust_cd,  :building_cd, :building_nm, :building_address, :owner_cd, :building_type_cd, :room_type_nm, :biru_age ).select(:eigyo_cd).select(:eigyo_nm).select(:trust_cd).select(:building_cd).select(:building_nm).select(:building_address).select(:owner_cd).select(:building_type_cd).select(:room_type_nm).select(:biru_age).each do |imp|

    # 建物の登録
    biru = Building.unscoped.find_or_create_by_code(imp.building_cd)
    biru.code = imp.building_cd.chomp
    biru.name = imp.building_nm.chomp
    biru.address = imp.building_address.chomp
    biru.build_type_id = convert_biru_type(imp.building_type_cd)
    biru.room_num = imp.room_type_nm
    biru.shop_id = convert_shop(imp.eigyo_cd)
    biru.biru_age = imp.biru_age # TODO:築年数も設定する。
    biru.delete_flg = false

    # 一時対応
    if biru.latitude
	    biru_geocode(biru, false)
    else
	    biru_geocode(biru, true)
    end

    begin
      biru.save!
    rescue =>e
      #p "エラー:save " + biru.name + ':' + biru.address
      p "建物登録エラー:save :" + e.message
    end

    # 部屋の登録
    kanri_room_num = 0 # 管理戸数
    free_num = 0
    owner_stop_num = 0

    ImpTable.find_all_by_building_cd(biru.code).each do |imp_room|

      room = Room.unscoped.find_or_create_by_building_cd_and_code(biru.code, imp_room.room_cd)
      room.building = biru
      room.name = imp_room.room_nm
      room.room_layout = RoomLayout.find_by_code(imp_room.room_layout_cd)
      room.room_type = RoomType.find_by_code(imp_room.room_type_cd)

      kanri_room_num = kanri_room_num + 1 # TODO:本来はB管理以上とかが必要かも。管理方式に戸数カウントフラグを持たせてそれで判定させよう。

      # 空き状態の設定
      if imp_room.room_aki == 2
        room.free_state = true
        free_num = free_num + 1
        p room.building_cd.to_s + ' ' + room.code + ' ' + '空き'
      else
        room.free_state = false
        p room.building_cd.to_s + ' ' + room.code + ' ' + '入居'
      end

      # TODO:オーナー止も取得する。
      room.delete_flg = false
      room.save!

      #p biru.name + ' ' + room.name

    end

    # 部屋の集計値を建物に登録
    biru.kanri_room_num = kanri_room_num
    biru.free_num = free_num
    biru.owner_stop_num = owner_stop_num

    begin
      biru.save!
    rescue =>e
      p "建物登録エラー2:save :" + e.message
    end
  end

  ####################
  # 管理委託契約の登録
  ####################
  p "■委託登録（" + Time.now.to_s(:db) + "）"
  ImpTable.group( :trust_cd, :owner_cd, :building_cd, :manage_type_cd ).select(:trust_cd).select(:owner_cd).select(:building_cd).select(:manage_type_cd).each do |imp|

    trust = Trust.unscoped.find_or_create_by_code(imp.trust_cd)
    biru = Building.where("code=?",imp.building_cd).first
    if biru
      owner = Owner.where("code=?", imp.owner_cd).first
      if owner
        # 建物と貸主が存在している時
        trust.code = imp.trust_cd
        trust.building_id = biru.id
        trust.owner_id = owner.id
        trust.delete_flg = false

        trust.manage_type_id = ManageType.where("code=?", imp.manage_type_cd.to_i).first.id

        trust.save!
        #p trust.code
      end

    end
  end

end


# アタック対象の貸主・物件・委託（ダミー）を登録します。
def import_data_yourself_owner(filename)

  # ファイル存在チェック
  unless File.exist?(filename)
    puts 'file not exist'
    return false
  end

  # imp_tablesを初期化
  ImpTable.delete_all

  # 他社元データを一時表に登録
  cnt = 0
  open(filename).each do |line|
    catch :not_header do

      if cnt == 0
        cnt = cnt + 1
        throw :not_header
      end

      cnt = cnt + 1

      row = line.split(",")

      unless row[10]
        throw :not_header
      end

      imp = ImpTable.new
#      imp.siten_cd = row[0]
#      imp.eigyo_order = row[1]
      imp.eigyo_cd = row[1]
      imp.eigyo_nm = row[2]
#      imp.kanri_cd = row[4]
#      imp.kanri_nm = row[5]
#      imp.trust_cd = row[6]
      imp.building_cd = row[11]
      imp.building_nm = row[12]
      imp.building_address = row[15]
      imp.building_type_code = row[19]
#      imp.room_cd = row[9]
#      imp.room_nm = row[10]
#      imp.kanri_start_date = row[11]
#      imp.kanri_end_date = row[12]
#      imp.room_aki = row[13]
#      imp.room_type_cd = row[14]
#      imp.room_type_nm = row[15]
#      imp.room_layout_cd = row[16]
#      imp.room_layout_nm = row[17]
      imp.owner_cd = row[0]
      imp.owner_nm = row[3]
#      imp.owner_kana = row[20]
      imp.owner_address = row[5]
      imp.owner_tel = row[6]
      imp.save!

      if imp
        p cnt.to_s + " " + imp.building_nm
      else
        p cnt.to_s
      end
    end
  end

  # 他社の初期化(削除フラグをON)
  before_imp_init(2)

  ####################
  # 貸主の登録
  ####################
  ImpTable.group(:owner_cd, :owner_nm, :owner_address ).each do |imp|
  catch :next_owner do

    owner = Owner.unscoped.find_or_create_by_attack_code(imp.owner_cd)
    owner.attack_code = imp.owner_cd
    owner.name = imp.owner_nm
    owner.address = imp.owner_address
    owner.delete_flg = false
    biru_geocode(owner, false)
    begin
      owner.save!

    rescue
      #p "エラー:save " + biru.name + ':' + biru.address
      p "貸主登録エラー:save "
      throw :next_owner
    end

    ##############
    # 建物
    ##############
    ImpTable.where(:owner_cd=>imp.owner_cd).group(:eigyo_cd, :eigyo_nm, :building_cd, :building_nm, :building_address, :building_type_code ).each do |imp_biru|
    catch :next_building do

      # 建物の登録
      biru = Building.unscoped.find_or_create_by_attack_code(imp_biru.building_cd)
      biru.attack_code = imp_biru.building_cd
      biru.name = imp_biru.building_nm
      biru.delete_flg = false

      biru.build_type_id = convert_biru_type(imp_biru.building_type_code)
      if biru.build_type_id
        biru.tmp_build_type_icon = biru.build_type.icon
      end

      biru.shop_id = convert_shop(imp_biru.eigyo_cd)
      # biru.room_num = row[13]

      biru.address = imp_biru.building_address
      #biru.gmaps = true
      biru_geocode(biru, false)

      begin
        biru.save!
      rescue =>e
        #p "エラー:save " + biru.name + ':' + biru.address
        p "建物登録エラー:save :" + e.message
        throw :next_owner
      end

      # 管理委託契約を登録
      trust = Trust.unscoped.find_or_create_by_building_id_and_owner_id(biru.id, owner.id)
      trust.delete_flg = false
      trust.code = 99999
      trust.manage_type = ManageType.find_by_code(99)
      trust.save!

    end # catch
    end

  end # catch
  end

end

# 営業所登録
init_shop

# 物件種別登録
#init_biru_type

# 管理方式登録rak
#init_manage_type

# 部屋種別登録
#init_room_type

# 部屋間取登録
#init_room_layout

# データの登録(自社)
#import_data_oneself(Rails.root.join( "tmp", "imp_data_20131108.csv"))

# データの登録(他社)
#import_data_yourself_owner(Rails.root.join( "tmp", "attack_owner1102.csv"))

def update_gmap
  Owner.unscoped.each do |owner|
    o_has = Owner.find_by_sql("select * from backup_owners where code = " + owner.code)
    o_has.each do |o_has_one|
      owner.latitude = o_has_one.latitude
      owner.longitude = o_has_one.longitude
      owner.gmaps = true
      owner.save!
    end
  end

  Building.unscoped.each do |biru|
    a_has = Building.find_by_sql("select * from backup_buildings where code = " + biru.code)
    a_has.each do |a_has_one|
      biru.latitude = a_has_one.latitude
      biru.longitude = a_has_one.longitude
      biru.gmaps = true
      biru.save!
    end
  end
end


#update_gmap


# geocode されていないものをアップデート
def update_geocode

  # 貸主
  Owner.unscoped.where(:latitude => nil).each do |owner|
    unless biru_geocode(owner, true)
      owner.delete_flg = true
    end
    owner.save!
  end

  # 建物
  Building.unscoped.where(:latitude => nil).each do |biru|
    unless biru_geocode(biru, true)
      biru.delete_flg = true
    end
    biru.save!
  end

end

#update_geocode
