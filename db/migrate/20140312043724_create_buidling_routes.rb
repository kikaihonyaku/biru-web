class CreateBuidlingRoutes < ActiveRecord::Migration
  def change
    create_table :building_routes do |t|
      t.integer :building_id
      t.string :code
      t.integer :station_id
      t.boolean :bus, :default=>false
      t.integer :minutes
      t.timestamps
    end

    add_column :imp_tables, :moyori_id, :string
    add_column :imp_tables, :line_cd, :string
    add_column :imp_tables, :line_nm, :string
    add_column :imp_tables, :station_cd, :string
    add_column :imp_tables, :station_nm, :string
    add_column :imp_tables, :bus_exists, :integer
    add_column :imp_tables, :minuite, :integer

  end
end
