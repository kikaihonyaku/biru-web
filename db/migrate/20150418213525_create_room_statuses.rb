class CreateRoomStatuses < ActiveRecord::Migration
  def change
    create_table :room_statuses do |t|
      t.string :code
      t.string :name
      t.timestamps
    end
    
    add_column :rooms, :room_status_id, :integer
    add_index :rooms, :room_status_id
    
    add_column :imp_tables, :room_status_nm, :string
  end
end
