  class RecruitmentsController < ApplicationController

  before_filter :init

  def init
    
    # 物件種別指定
    @build_type_checked = {}
    @build_type_checked[:apart] = false
    @build_type_checked[:man] = false
    @build_type_checked[:bman] = false
    @build_type_checked[:tenpo] = false
    @build_type_checked[:jimusyo] = false
    @build_type_checked[:kojo] = false
    @build_type_checked[:soko] = false
    @build_type_checked[:kodate] = false
    @build_type_checked[:terasu] = false
    @build_type_checked[:mezo] = false
    @build_type_checked[:ten_jyu] = false
    @build_type_checked[:soko_jimu] = false
    @build_type_checked[:kojo_soko] = false
    @build_type_checked[:syakuti] = false


    @layout_type_checked = {}
    @layout_type_checked[:layout_1r] = false
    @layout_type_checked[:layout_1k] = false
    @layout_type_checked[:layout_1dk] = false
    @layout_type_checked[:layout_1ldk] = false
    @layout_type_checked[:layout_2k] = false
    @layout_type_checked[:layout_2dk] = false
    @layout_type_checked[:layout_2ldk] = false
    @layout_type_checked[:layout_3k] = false
    @layout_type_checked[:layout_3dk] = false
    @layout_type_checked[:layout_3ldk] = false
    @layout_type_checked[:layout_4k] = false
    @layout_type_checked[:layout_4dk] = false
    @layout_type_checked[:layout_4ldk] = false
    
    @buildings = []
    @shops = []

    # タブ表示
    @tab_search = "active in"
    @tab_result = ""

  end

  def index

    # 表示する建物が存在しない時
    @shops =  Shop.find(:all)

    gon.buildings = @buildings
    gon.shops = @shops    # 関連する営業所
    
  end

  # 検索
  def search

    search_result_init(1)
    tmp_room = Room.joins(:building).joins(:building => :shop).includes(:building).includes(:building => :shop).scoped

    # 物件種別で絞り込み
    if params[:build_type]
      build_type = []
      params[:build_type].keys.each do |key|
        build_type.push(BuildType.find_by_code(params[:build_type][key]).id)
        @build_type_checked[key.to_sym] = true
      end
      tmp_room = tmp_room.where('buildings.build_type_id'=>build_type)
    end


    # 間取りが選択されていたらそれを絞り込む
    if params[:layout_type]
      layout_arr = []
      params[:layout_type].keys.each do |key|
        RoomLayout.conv_param(params[:layout_type][key].to_i, layout_arr)
        @layout_type_checked[key.to_sym] = true
      end

      tmp_room = tmp_room.where(:room_layout_id => layout_arr)
    end



    # 間取りを展開
    buildings = []
    shops = []
    room_of_building = []
    tmp_room.each do |room|


      biru = room.building

      room_of_building[biru.id] = [] unless room_of_building[biru.id]
      room_of_building[biru.id] << room
      
      buildings << biru
      shops << biru.shop

    end

    if buildings.uniq
      @buildings = buildings.uniq
      @shops = shops.uniq
   else
      @shops =  Shop.find(:all)
    end

 
    gon.shops = @shops    # 関連する営業所
    gon.buildings = @buildings
    gon.room_of_building = room_of_building
    gon.around_flg = false
    

    render 'index'

  end

  # 周辺検索
  def search_around()

    @buildings = []
    @shops = []
    room_of_building = []
    search_result_init(1)


    p params[:around]
    biru = Building.find(params[:around])
    if biru
      room_of_building[biru.id] = []

      @buildings << biru
      @shops << biru.shop

      biru.rooms.each do |room|
        room_of_building[biru.id] << room
      end

    else
      @shops =  Shop.find(:all)
    end

    gon.shops = @shops    # 関連する営業所
    gon.buildings = @buildings
    gon.room_of_building = room_of_building
    gon.around_flg = true


    render 'index'
  end
end
