class CreateLoginHistories < ActiveRecord::Migration
  def change
    create_table :login_histories do |t|
      t.integer :biru_user_id
      t.string :code
      t.string :name
      t.timestamps
    end
  end
end
