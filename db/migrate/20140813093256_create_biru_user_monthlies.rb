class CreateBiruUserMonthlies < ActiveRecord::Migration
  def change
    create_table :biru_user_monthlies do |t|
      t.integer :biru_user_id
      t.string :month
      t.integer :trust_plan_visit
      t.integer :trust_plan_dm
      t.integer :trust_plan_tel
      t.timestamps
    end
  end
end
