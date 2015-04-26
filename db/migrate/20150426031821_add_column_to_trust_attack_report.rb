class AddColumnToTrustAttackReport < ActiveRecord::Migration
  def change
    add_column :trust_attack_month_reports, :suggestion_num, :integer
    add_column :trust_attack_month_reports, :trust_plan, :integer
    add_column :trust_attack_month_reports, :trust_num_jisya, :integer
    add_column :trust_attack_month_reports, :rank_w, :integer
    add_column :trust_attack_month_reports, :rank_x, :integer
    add_column :trust_attack_month_reports, :rank_y, :integer
    add_column :trust_attack_month_reports, :rank_z, :integer
  end
end
