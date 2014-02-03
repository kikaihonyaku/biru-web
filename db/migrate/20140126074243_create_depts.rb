class CreateDepts < ActiveRecord::Migration
  def change
    create_table :depts do |t|
      t.string :busyo_id
      t.string :code
      t.string :name
      t.boolean :delete_flg , :default=>false
      t.timestamps
    end
  end
end
