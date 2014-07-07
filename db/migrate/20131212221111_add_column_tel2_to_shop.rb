class AddColumnTel2ToShop < ActiveRecord::Migration
  def change
    add_column :shops, :tel2, :string
  end
end
