class AddColumnToImpTables < ActiveRecord::Migration
  def change
    add_column :imp_tables, :owner_postcode, :string
    add_column :imp_tables, :owner_honorific_title, :string
    add_column :imp_tables, :owner_memo, :text
    add_column :imp_tables, :building_memo, :text
    
    add_column :owners, :postcode, :string
    add_column :owners, :honorific_title, :string
    add_column :owners, :tel, :string
  end
end
