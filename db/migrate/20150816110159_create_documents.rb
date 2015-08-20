class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      
      t.integer :owner_id
      t.integer :building_id
      
      
      # t.attachment :doc_file
      t.string :file_name
      t.integer :biru_user_id
      t.boolean :delete_flg, :default => false
      
      t.timestamps
    end
  end
end
