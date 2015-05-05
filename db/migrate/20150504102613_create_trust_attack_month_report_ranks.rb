class CreateTrustAttackMonthReportRanks < ActiveRecord::Migration
  def change
    
    create_table :trust_attack_month_report_ranks do |t|
      t.integer :trust_attack_month_report_id
      t.integer :attack_state_last_month_id
      t.integer :attack_state_this_month_id
      t.integer :change_status
      t.string  :change_month
      t.integer :trust_id
      t.integer :owner_id
      t.integer :building_id
      t.string :building_name
      t.float   :building_latitude
      t.float   :building_longitude
      t.boolean :delete_flg, :default=>false
      t.timestamps
    end
    
    add_index :trust_attack_month_report_ranks, :building_id
    add_index :trust_attack_month_report_ranks, :trust_attack_month_report_id, :name=>:trsut_attack_report_rank_report_id
  end
end
