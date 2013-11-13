# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131113204122) do

  create_table "backup_buildings", :force => true do |t|
    t.string   "code",                 :limit => nil
    t.string   "name"
    t.string   "address"
    t.integer  "shop_id"
    t.integer  "build_type_id"
    t.integer  "room_num"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.string   "tmp_manage_type_icon"
    t.string   "tmp_build_type_icon"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.integer  "building_rank_id"
    t.text     "memo"
    t.boolean  "delete_flg",                          :default => false
    t.integer  "attack_code"
  end

  create_table "backup_owners", :force => true do |t|
    t.integer  "code"
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
    t.integer  "attack_code"
  end

  create_table "build_types", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "icon"
  end

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
    t.boolean  "delete_flg",           :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "tmp_build_type_icon"
    t.string   "tmp_manage_type_icon"
    t.integer  "kanri_room_num",       :default => 0
    t.integer  "free_num",             :default => 0
    t.integer  "owner_stop_num",       :default => 0
    t.integer  "biru_age",             :default => 0
  end

  add_index "buildings", ["build_type_id"], :name => "index_buildings_on_build_type_id"
  add_index "buildings", ["shop_id"], :name => "index_buildings_on_shop_id"

  create_table "imp_tables", :force => true do |t|
    t.integer "siten_cd"
    t.integer "eigyo_order"
    t.integer "eigyo_cd"
    t.string  "eigyo_nm"
    t.integer "manage_type_cd"
    t.string  "manage_type_nm"
    t.integer "trust_cd"
    t.integer "building_cd"
    t.string  "building_nm"
    t.integer "room_cd"
    t.string  "room_nm"
    t.string  "kanri_start_date"
    t.string  "kanri_end_date"
    t.integer "room_aki"
    t.string  "room_type_cd"
    t.string  "room_type_nm"
    t.string  "room_layout_cd"
    t.string  "room_layout_nm"
    t.integer "owner_cd"
    t.string  "owner_nm"
    t.string  "owner_kana"
    t.string  "owner_address"
    t.string  "owner_tel"
    t.string  "building_address"
    t.string  "building_type_code"
    t.integer "biru_age"
  end

  create_table "manage_types", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "icon"
    t.string "line_color"
  end

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

  create_table "room_layouts", :force => true do |t|
    t.string "code"
    t.string "name"
  end

  create_table "room_types", :force => true do |t|
    t.string "code"
    t.string "name"
  end

  create_table "rooms", :force => true do |t|
    t.integer  "building_cd"
    t.string   "code"
    t.string   "name"
    t.integer  "room_type_id"
    t.integer  "room_layout_id"
    t.integer  "trust_id"
    t.integer  "manage_type_id"
    t.integer  "building_id"
    t.integer  "rent"
    t.boolean  "delete_flg",       :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "free_state",       :default => true
    t.boolean  "owner_stop_state", :default => false
    t.boolean  "advertise_state",  :default => false
  end

  create_table "shops", :force => true do |t|
    t.string  "code"
    t.string  "name"
    t.string  "address"
    t.float   "latitude"
    t.float   "longitude"
    t.boolean "gmaps"
    t.string  "icon"
    t.integer "area_id"
    t.integer "group_id"
    t.string  "tel"
    t.string  "holiday"
  end

  add_index "shops", ["area_id"], :name => "index_shops_on_area_id"
  add_index "shops", ["group_id"], :name => "index_shops_on_group_id"

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

end
