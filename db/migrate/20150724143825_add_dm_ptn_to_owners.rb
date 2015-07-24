class AddDmPtnToOwners < ActiveRecord::Migration
  def change
    add_column :owners, :dm_ptn_1, :boolean, :default=>false
    add_column :owners, :dm_ptn_2, :boolean, :default=>false
    add_column :owners, :dm_ptn_3, :boolean, :default=>false
    add_column :owners, :dm_ptn_4, :boolean, :default=>false
  end
end
