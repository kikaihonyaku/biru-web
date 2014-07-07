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

ActiveRecord::Schema.define(:version => 20140707210120) do

  create_table "approach_kinds", :force => true do |t|
    t.string "name"
  end

  create_table "attack_states", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.integer  "order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "biru_users", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "password"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "attack_all_search", :default => false
    t.string   "syain_id"
  end

  create_table "build_types", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "icon"
  end

  create_table "building_routes", :force => true do |t|
    t.integer  "building_id"
    t.string   "code"
    t.integer  "station_id"
    t.boolean  "bus",         :default => false
    t.integer  "minutes"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
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
    t.string   "build_day"
    t.integer  "main_employee_id"
    t.integer  "attack_state_id"
  end

  add_index "buildings", ["build_type_id"], :name => "index_buildings_on_build_type_id"
  add_index "buildings", ["shop_id"], :name => "index_buildings_on_shop_id"

  create_table "dept_group_details", :force => true do |t|
    t.integer  "dept_group_id"
    t.integer  "dept_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "dept_groups", :force => true do |t|
    t.string   "busyo_id"
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "depts", :force => true do |t|
    t.string   "busyo_id"
    t.string   "code"
    t.string   "name"
    t.boolean  "delete_flg", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "employes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "password"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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
    t.string  "building_address"
    t.string  "building_type_cd"
    t.integer "biru_age"
    t.string  "build_day"
    t.string  "moyori_id"
    t.string  "line_cd"
    t.string  "line_nm"
    t.string  "station_cd"
    t.string  "station_nm"
    t.integer "bus_exists"
    t.integer "minuite"
    t.string  "owner_postcode"
    t.string  "owner_honorific_title"
    t.text    "owner_memo"
    t.text    "building_memo"
    t.integer "owner_type"
    t.integer "building_type"
    t.integer "execute_status",        :default => 0
    t.string  "execute_msg"
  end

  create_table "items", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "lease_contracts", :force => true do |t|
    t.string   "code"
    t.string   "start_date"
    t.string   "leave_date"
    t.integer  "building_id"
    t.integer  "room_id"
    t.integer  "lease_month"
    t.integer  "rent"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "lines", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "login_histories", :force => true do |t|
    t.integer  "biru_user_id"
    t.string   "code"
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "manage_types", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "icon"
    t.string "line_color"
  end

  create_table "monthly_statements", :force => true do |t|
    t.integer  "dept_id"
    t.integer  "item_id"
    t.string   "yyyymm"
    t.decimal  "plan_value",   :precision => 11, :scale => 2
    t.decimal  "result_value", :precision => 11, :scale => 2
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "monthly_statements", ["dept_id", "item_id", "yyyymm"], :name => "index_monthly_all"
  add_index "monthly_statements", ["dept_id"], :name => "index_monthly_dept"
  add_index "monthly_statements", ["item_id"], :name => "index_monthly_item"
  add_index "monthly_statements", ["yyyymm"], :name => "index_monthly_yyyymm"

  create_table "owner_approaches", :force => true do |t|
    t.integer  "owner_id"
    t.date     "approach_date"
    t.integer  "approach_kind_id"
    t.string   "content"
    t.integer  "biru_user_id"
    t.boolean  "delete_flg"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "owner_building_logs", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "building_id"
    t.integer  "trust_id"
    t.text     "message"
    t.integer  "biru_user_id"
    t.boolean  "delete_flg",   :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "owners", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.text     "memo"
    t.integer  "owner_rank_id"
    t.boolean  "delete_flg",       :default => false
    t.string   "attack_code"
    t.string   "postcode"
    t.string   "honorific_title"
    t.string   "tel"
    t.boolean  "dm_delivery",      :default => true
    t.integer  "main_employee_id"
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
    t.string  "tel2"
    t.boolean "delete_flg", :default => false
  end

  add_index "shops", ["area_id"], :name => "index_shops_on_area_id"
  add_index "shops", ["group_id"], :name => "index_shops_on_group_id"

  create_table "stations", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "line_code"
    t.integer  "line_id"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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

  create_table "vacant_rooms", :force => true do |t|
    t.string   "yyyymm"
    t.integer  "room_id"
    t.integer  "shop_id"
    t.integer  "building_id"
    t.integer  "manage_type_id"
    t.integer  "room_layout_id"
    t.string   "vacant_start_day"
    t.integer  "vacant_cnt"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

end
