class AddDeleteFlgToShops < ActiveRecord::Migration
  def change
    add_column :shops, :delete_flg, :boolean, :default=>false
  end
end
