class AddImpTablesRelation < ActiveRecord::Migration
  def change
    add_column :imp_tables, :list_no, :string
    add_column :imp_tables, :owner_hash, :string
    add_column :imp_tables, :building_hash, :string
    add_column :owners, :hash_key, :string
    add_column :buildings, :hash_key, :string
    
  end

end
