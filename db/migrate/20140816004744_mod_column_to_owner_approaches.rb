class ModColumnToOwnerApproaches < ActiveRecord::Migration
  def change
    change_column :owner_approaches, :delete_flg, :boolean, :default => false    
  end
end
