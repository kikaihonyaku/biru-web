class CreateLines < ActiveRecord::Migration
  def change
    create_table :lines do |t|
      t.string "code"
      t.string "name"
      t.timestamps
    end
  end
end
