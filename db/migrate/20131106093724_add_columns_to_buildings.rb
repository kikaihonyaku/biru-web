class AddColumnsToBuildings < ActiveRecord::Migration
  def change
    # 建物の管理戸数・空室数・オーナー止め数・築年数数を保存
    add_column :buildings, :kanri_room_num, :integer, :default=>0
    add_column :buildings, :free_num, :integer, :default=>0
    add_column :buildings, :owner_stop_num, :integer, :default=>0
    add_column :buildings, :biru_age, :integer, :default=>0

    # 部屋のオーナー止状態・空室入居状態・募集中状態・空日数状態を保存
    add_column :rooms, :free_state, :boolean, :default=>true
    add_column :rooms, :owner_stop_state, :boolean, :default=>false
    add_column :rooms, :advertise_state, :boolean, :default=>false
  end
end
