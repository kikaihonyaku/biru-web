class AddAttackRegistColumn < ActiveRecord::Migration
  def change
  	add_column :imp_tables, :biru_user_id, :integer
  	
  end
end
