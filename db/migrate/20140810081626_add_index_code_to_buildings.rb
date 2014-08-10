class AddIndexCodeToBuildings < ActiveRecord::Migration
  def change
    add_index :buildings, :code
    add_index :buildings, :attack_code
    add_index :buildings, :name
  end
end
