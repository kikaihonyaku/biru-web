class InitDatabase < ActiveRecord::Migration
  def change

    ###########################
    # マスタテーブル
    ###########################

    # 物件種別マスタ
    create_table "build_types", :force => true do |t|
      t.string   "code"
      t.string   "name"
      t.string   "icon"
    end

    # 間取りマスタ
    create_table "room_layouts", :force => true do |t|
      t.string "code"
      t.string "name"
    end

    # 部屋種別マスタ
    create_table "room_types", :force => true do |t|
      t.string "code"
      t.string "name"
    end
    
    # 管理方式マスタ
    create_table "manage_types", :force => true do |t|
      t.string   "code"
      t.string   "name"
      t.string   "icon"
      t.string   "line_color"
    end

    # 営業所マスタ
    create_table "shops", :force => true do |t|
      t.string   "code"
      t.string   "name"
      t.string   "address"
      t.float    "latitude"
      t.float    "longitude"
      t.boolean  "gmaps"
      t.string   "icon"
      t.integer  "area_id"
      t.integer  "group_id"
    end

    add_index "shops", ["area_id"], :name => "index_shops_on_area_id"
    add_index "shops", ["group_id"], :name => "index_shops_on_group_id"

    
    ###########################
    # トランザクションテーブル
    ###########################

    # 貸主情報
    create_table "owners", :force => true do |t|
      t.string   "code"
      t.string   "name"
      t.string   "address"
      t.float    "latitude"
      t.float    "longitude"
      t.boolean  "gmaps"
      t.datetime "created_at",                       :null => false
      t.datetime "updated_at",                       :null => false
      t.text     "memo"
      t.integer  "owner_rank_id"
      t.boolean  "delete_flg",    :default => false
      t.string   "attack_code"
    end

    # 管理委託契約情報
    create_table "trusts", :force => true do |t|
      t.integer  "owner_id"
      t.integer  "building_id"
      t.integer  "manage_type_id"
      t.string   "code"
      t.datetime "created_at",                        :null => false
      t.datetime "updated_at",                        :null => false
      t.boolean  "delete_flg",     :default => false
    end

    add_index "trusts", ["building_id"], :name => "index_trusts_on_building_id"
    add_index "trusts", ["manage_type_id"], :name => "index_trusts_on_manage_type_id"
    add_index "trusts", ["owner_id"], :name => "index_trusts_on_owner_id"


    # 建物情報
    create_table "buildings", :force => true do |t|
      t.string   "code"
      t.string   "attack_code"
      t.string   "name"
      t.string   "address"
      t.float    "latitude"
      t.float    "longitude"
      t.boolean  "gmaps"
      t.integer  "shop_id"
      t.integer  "build_type_id"
      t.integer  "room_num"
      t.text     "memo"
      t.boolean  "delete_flg", :default => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "buildings", ["build_type_id"], :name => "index_buildings_on_build_type_id"
    add_index "buildings", ["shop_id"], :name => "index_buildings_on_shop_id"

    # 部屋情報
    create_table "rooms", :force => true do |t|
      t.integer "building_cd"
      t.string  "code"
      t.string  "name"
      t.integer "room_type_id"
      t.integer "room_layout_id"
      t.integer "trust_id"
      t.integer "manage_type_id"
      t.integer "building_id"
      t.integer "rent"
      t.boolean "delete_flg",     :default => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end


    ###########################
    # 一時作業用テーブル
    ###########################

    # 取り込みテーブル
    create_table "imp_tables", :force => true do |t|
      t.string  "siten_cd"
      t.string  "eigyo_order"
      t.string  "eigyo_cd"
      t.string  "eigyo_nm"
      t.string  "manage_type_cd"
      t.string  "manage_type_nm"
      t.string  "trust_cd"
      t.string  "building_cd"
      t.string  "building_nm"
      t.string  "room_cd"
      t.string  "room_nm"
      t.string  "kanri_start_date"
      t.string  "kanri_end_date"
      t.integer "room_aki"
      t.string  "room_type_cd"
      t.string  "room_type_nm"
      t.string  "room_layout_cd"
      t.string  "room_layout_nm"
      t.string  "owner_cd"
      t.string  "owner_nm"
      t.string  "owner_kana"
      t.string  "owner_address"
      t.string  "owner_tel"
    end


  end

end
