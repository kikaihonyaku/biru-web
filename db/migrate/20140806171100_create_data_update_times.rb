class CreateDataUpdateTimes < ActiveRecord::Migration
  def change
    create_table :data_update_times do |t|
      t.string :code
      t.string :name
      t.datetime :start_datetime
      t.datetime :update_datetime
      t.integer :biru_user_id
      t.timestamps
    end
  end
end
