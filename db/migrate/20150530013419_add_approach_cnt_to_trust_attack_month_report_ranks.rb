class AddApproachCntToTrustAttackMonthReportRanks < ActiveRecord::Migration
  def change
    add_column :trust_attack_month_report_ranks, :approach_cnt, :integer
  end
end
