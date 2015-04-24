class CreateTrustAttackMonthReports < ActiveRecord::Migration
  def change
    create_table :trust_attack_month_reports do |t|

      t.string :month
      t.integer :biru_user_id
      t.string :biru_usr_name
      t.string :trust_report_url
      t.string :attack_list_url
      t.integer :visit_plan
      t.integer :visit_result
      t.integer :visit_value
      t.integer :dm_plan
      t.integer :dm_result
      t.integer :dm_value
      t.integer :tel_plan
      t.integer :tel_result
      t.integer :tel_value
      t.integer :trust_num
      t.integer :rank_s
      t.integer :rank_a
      t.integer :rank_b
      t.integer :rank_c
      t.integer :rank_d
      t.integer :rank_c_over
      t.integer :rank_d_over
      t.integer :rank_all
      
      t.timestamps
    end
  end
  
  # add_index :trust_attack_month_reports, :biru_user_id
  # add_column :biru_users, :trust_staff_type, :integer
end



