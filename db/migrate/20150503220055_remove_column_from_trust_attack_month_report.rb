class RemoveColumnFromTrustAttackMonthReport < ActiveRecord::Migration
  def up
    remove_column :trust_attack_month_reports, :visit_owners_absence
    remove_column :trust_attack_month_reports, :visit_owners_meet
    remove_column :trust_attack_month_reports, :visit_owners_suggestion
    remove_column :trust_attack_month_reports, :dm_owners_send
    remove_column :trust_attack_month_reports, :dm_owners_recv
    remove_column :trust_attack_month_reports, :tel_owners_call
    remove_column :trust_attack_month_reports, :tel_owners_talk

    remove_column :trust_attack_month_reports, :rank_s_trusts
    remove_column :trust_attack_month_reports, :rank_a_trusts
    remove_column :trust_attack_month_reports, :rank_b_trusts
    remove_column :trust_attack_month_reports, :rank_c_trusts
    remove_column :trust_attack_month_reports, :rank_z_trusts
    
  end
  
  def down
    
    add_column :trust_attack_month_reports, :visit_owners_absence, :text
    add_column :trust_attack_month_reports, :visit_owners_meet, :text
    add_column :trust_attack_month_reports, :visit_owners_suggestion, :text
    add_column :trust_attack_month_reports, :dm_owners_send, :text
    add_column :trust_attack_month_reports, :dm_owners_recv, :text
    add_column :trust_attack_month_reports, :tel_owners_call, :text
    add_column :trust_attack_month_reports, :tel_owners_talk, :text

    add_column :trust_attack_month_reports, :rank_s_trusts, :text
    add_column :trust_attack_month_reports, :rank_a_trusts, :text
    add_column :trust_attack_month_reports, :rank_b_trusts, :text
    add_column :trust_attack_month_reports, :rank_c_trusts, :text
    add_column :trust_attack_month_reports, :rank_z_trusts, :text
    
  end
  
end
