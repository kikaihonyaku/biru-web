class AddBuildDayToBuildings < ActiveRecord::Migration
  def change
    add_column :imp_tables, :build_day, :string
    add_column :buildings, :build_day, :string
  end
end
