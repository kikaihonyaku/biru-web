class AddIndexApproachKindToOwnerApproaches < ActiveRecord::Migration
  def change
    add_index :owner_approaches, :approach_kind_id
    add_index :owner_approaches, :approach_date
    
  end
end
