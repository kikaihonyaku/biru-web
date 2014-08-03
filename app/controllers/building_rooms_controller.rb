class BuildingRoomsController < ApplicationController
  def index
    @building_rooms = initialize_grid(Room.joins(:building => :shop).joins(:building => :trusts).joins("LEFT OUTER JOIN renters_rooms on rooms.renters_room_id = renters_rooms.id"))
  end
end
