class AddKeyToImpTables < ActiveRecord::Migration
  def change
    add_column :imp_tables, :batch_code,  :string
  end
end
