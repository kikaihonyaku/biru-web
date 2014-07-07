class CreateBiruUsers < ActiveRecord::Migration
  def change
    create_table :biru_users do |t|
      t.string :code, :unique=>true
      t.string :name
      t.string :password

      t.timestamps
    end
  end
end
