class AddColumnToShop < ActiveRecord::Migration
  def change
    add_column :shops, :tel, :string
    add_column :shops, :holiday, :string
  end
end
