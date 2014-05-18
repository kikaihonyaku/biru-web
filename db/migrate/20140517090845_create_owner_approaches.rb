class CreateOwnerApproaches < ActiveRecord::Migration
  def change
    create_table :owner_approaches do |t|
      t.integer :owner_id
      t.date :approach_date
      t.integer :approach_kind_id
      t.string  :content
      t.integer :biru_user_id
      t.boolean :delete_flg
      t.timestamps
    end
    
  end
end
