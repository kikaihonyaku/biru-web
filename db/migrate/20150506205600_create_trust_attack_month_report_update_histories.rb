class CreateTrustAttackMonthReportUpdateHistories < ActiveRecord::Migration
  def change
    create_table :trust_attack_month_report_update_histories do |t|
      t.string :month
      t.datetime :start_datetime
      t.datetime :update_datetime
      t.timestamps
    end
  end
end
