class AddBiruRankToImpTables < ActiveRecord::Migration
  def change
  	add_column :imp_tables, :biru_rank, :string
  end
end
