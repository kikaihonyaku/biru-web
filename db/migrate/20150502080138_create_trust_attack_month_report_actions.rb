class CreateTrustAttackMonthReportActions < ActiveRecord::Migration
  def change
    create_table :trust_attack_month_report_actions do |t|
      t.integer :trust_attack_month_report_id
      t.integer :owner_approach_id
      # t.string :month
      # t.integer :owner_id
      # t.date :approach_date
      # t.integer :approach_kind_id
      # t.string  :content
      # t.integer :biru_user_id
      t.timestamps
    end
    
    add_index :trust_attack_month_report_actions, :trust_attack_month_report_id, :name => ':trust_attack_month_report_id_pk'
    add_index :trust_attack_month_report_actions, :owner_approach_id, :name => ':trust_attack_month_report_owner_approach_pk'
  end
end
