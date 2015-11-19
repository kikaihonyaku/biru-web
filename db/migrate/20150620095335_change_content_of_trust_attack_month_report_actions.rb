class ChangeContentOfTrustAttackMonthReportActions < ActiveRecord::Migration
  def up
    change_column :trust_attack_month_report_actions, :content, :text
  end

  def down
    change_column :trust_attack_month_report_actions, :content, :string
  end
end
