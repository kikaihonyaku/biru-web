class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :comment_type
      t.string :code
      t.string :sub_code
      t.text :content
      t.integer :biru_user_id
      t.boolean :delete_flg, :default=>false

      t.timestamps
    end
  end
end
