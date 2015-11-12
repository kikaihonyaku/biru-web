class AddColumnPostcodeAndSelectivelyFlgToBuildings < ActiveRecord::Migration
  def change
    add_column :buildings, :postcode, :string
    add_column :buildings, :selectively_flg, :boolean, :default=>false
  end
end
