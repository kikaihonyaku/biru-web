class CreateMonthlyStatements < ActiveRecord::Migration
  def change
    create_table :monthly_statements do |t|
      t.integer :dept_id
      t.integer :item_id
      t.string :yyyymm
      t.decimal :plan_value, :precision => 11, :scale => 2
      t.decimal :result_value, :precision => 11, :scale => 2
      t.timestamps
    end
  end
end
