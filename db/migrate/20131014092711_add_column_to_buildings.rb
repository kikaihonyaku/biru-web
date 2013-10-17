class AddColumnToBuildings < ActiveRecord::Migration
  def change
    add_column :buildings, :tmp_build_type_icon, :string
    add_column :buildings, :tmp_manage_type_icon, :string

  end
end
