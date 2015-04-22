class AddIndexApproachKindToOwnerApproaches < ActiveRecord::Migration
  def change
    add_index :owner_approaches, :approach_kind_id
  end
end
