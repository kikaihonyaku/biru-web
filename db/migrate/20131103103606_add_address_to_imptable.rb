class AddAddressToImptable < ActiveRecord::Migration
  def change
    add_column :imp_tables, :building_address, :string
    add_column :imp_tables, :building_type_cd, :string
  end
end
