class AddFlgToBiuldings < ActiveRecord::Migration
  def change
  	add_column :buildings, :neighborhood_flg, :boolean, :default=>0
  	add_column :buildings, :room_all_flg, :boolean, :default=>0
  end
end
