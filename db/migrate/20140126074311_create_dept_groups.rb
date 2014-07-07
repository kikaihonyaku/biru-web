class CreateDeptGroups < ActiveRecord::Migration
  def change
    create_table :dept_groups do |t|
      t.string :busyo_id
      t.string :code
      t.string :name
      t.timestamps
    end
  end
end
