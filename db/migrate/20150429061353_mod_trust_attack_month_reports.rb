class ModTrustAttackMonthReports < ActiveRecord::Migration
  def change
    remove_column :trust_attack_month_reports, :visit_result
    remove_column :trust_attack_month_reports, :visit_value
    remove_column :trust_attack_month_reports, :suggestion_num
    remove_column :trust_attack_month_reports, :dm_result
    remove_column :trust_attack_month_reports, :dm_value
    remove_column :trust_attack_month_reports, :tel_result
    remove_column :trust_attack_month_reports, :tel_value
    
    add_column :trust_attack_month_reports, :visit_num_all, :integer
    add_column :trust_attack_month_reports, :visit_num_meet, :integer
    add_column :trust_attack_month_reports, :dm_num_send, :integer
    add_column :trust_attack_month_reports, :dm_num_recv, :integer
    add_column :trust_attack_month_reports, :tel_num_call, :integer
    add_column :trust_attack_month_reports, :tel_num_talk, :integer
    
    add_column :trust_attack_month_reports, :suggestion_plan, :integer
    add_column :trust_attack_month_reports, :suggestion_num, :integer
    
    add_column :trust_attack_month_reports, :visit_owners_absence, :text
    add_column :trust_attack_month_reports, :visit_owners_meet, :text
    add_column :trust_attack_month_reports, :visit_owners_suggestion, :text
    add_column :trust_attack_month_reports, :dm_owners_send, :text
    add_column :trust_attack_month_reports, :dm_owners_recv, :text
    add_column :trust_attack_month_reports, :tel_owners_call, :text
    add_column :trust_attack_month_reports, :tel_owners_talk, :text
    
  end
end

