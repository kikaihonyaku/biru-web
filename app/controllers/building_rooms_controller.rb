class BuildingRoomsController < ApplicationController
  def index
    @data_update = DataUpdateTime.find_by_code("310")
    @building_rooms = initialize_grid(Room.joins(:building => :shop).joins(:building => :trusts).joins("LEFT OUTER JOIN manage_types on trusts.manage_type_id = manage_types.id ").joins("LEFT OUTER JOIN renters_rooms on rooms.renters_room_id = renters_rooms.id"))
  end
end
