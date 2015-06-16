class ChangeContentOfOwnerApproaches < ActiveRecord::Migration
  def up
    change_column :owner_approaches, :content, :text
  end

  def down
    change_column :owner_approaches, :content, :string
  end
end
