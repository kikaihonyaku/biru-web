  class RecruitmentsController < ApplicationController

  before_filter :init

  def init
  end

  def index

    # 表示する建物が存在しない時
    @buildings = []
    @shops =  Shop.find(:all)

    gon.buildings = @buildings
    gon.shops = @shops    # 関連する営業所
    
  end

  # 検索
  def search

    tmp_room = Room.joins(:building => :shop).includes(:building).includes(:building => :shop).scoped

    # 間取りが選択されていたらそれを絞り込む
    if params[:layout]
      layout_arr = []
      params[:layout].keys.each do |key|
        layout_arr.push(RoomLayout.find_by_code(params[:layout][key]).id)
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

    @buildings = buildings.uniq!
    @shops = shops.uniq!

    gon.shops = @shops    # 関連する営業所
    gon.buildings = @buildings
    gon.room_of_building = room_of_building
    gon.around_flg = false
    

    render 'index'
    #render 'test'

  end

  # 周辺検索
  def search_around()

    @buildings = []
    @shops = []
    room_of_building = []


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
