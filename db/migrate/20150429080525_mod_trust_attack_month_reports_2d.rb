class ModTrustAttackMonthReports2d < ActiveRecord::Migration
  def change
    add_column :trust_attack_month_reports, :rank_s_trusts, :text
    add_column :trust_attack_month_reports, :rank_a_trusts, :text
    add_column :trust_attack_month_reports, :rank_b_trusts, :text
    add_column :trust_attack_month_reports, :rank_c_trusts, :text
    add_column :trust_attack_month_reports, :rank_z_trusts, :text
  end
end
