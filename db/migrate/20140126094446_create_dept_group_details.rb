class CreateDeptGroupDetails < ActiveRecord::Migration
  def change
    create_table :dept_group_details do |t|
      t.integer :dept_group_id
      t.integer :dept_id
      t.timestamps
    end
  end
end
