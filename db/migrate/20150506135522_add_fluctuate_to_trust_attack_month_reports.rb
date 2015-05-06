class AddFluctuateToTrustAttackMonthReports < ActiveRecord::Migration
  def change
    add_column :trust_attack_month_reports, :fluctuate_s, :integer
    add_column :trust_attack_month_reports, :fluctuate_a, :integer
    add_column :trust_attack_month_reports, :fluctuate_b, :integer
    add_column :trust_attack_month_reports, :fluctuate_c, :integer
    add_column :trust_attack_month_reports, :fluctuate_d, :integer
    add_column :trust_attack_month_reports, :fluctuate_w, :integer
    add_column :trust_attack_month_reports, :fluctuate_x, :integer
    add_column :trust_attack_month_reports, :fluctuate_y, :integer
    add_column :trust_attack_month_reports, :fluctuate_z, :integer
  end
end
