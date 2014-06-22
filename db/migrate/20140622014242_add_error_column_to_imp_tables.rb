class AddErrorColumnToImpTables < ActiveRecord::Migration
  def change
    add_column :imp_tables, :owner_type, :integer
    add_column :imp_tables, :building_type, :integer
    add_column :imp_tables, :execute_status, :integer, :default=>0 # 0:未実行 1:正常終了 2:エラー
    add_column :imp_tables, :execute_msg, :string 
  end
end
