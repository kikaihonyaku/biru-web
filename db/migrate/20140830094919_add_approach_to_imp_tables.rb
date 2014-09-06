class AddApproachToImpTables < ActiveRecord::Migration
  def change
  	add_column :imp_tables, :approach_01, :string
  	add_column :imp_tables, :approach_02, :string
  	add_column :imp_tables, :approach_03, :string
  	add_column :imp_tables, :approach_04, :string
  	add_column :imp_tables, :approach_05, :string
  end
end
