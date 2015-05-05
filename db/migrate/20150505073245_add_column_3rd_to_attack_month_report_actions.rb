class AddColumn3rdToAttackMonthReportActions < ActiveRecord::Migration
  def change
    add_column :trust_attack_month_report_actions, :owner_id, :integer
    add_column :trust_attack_month_report_actions, :owner_code, :string
    add_column :trust_attack_month_report_actions, :owner_name, :string
    add_column :trust_attack_month_report_actions, :owner_address, :string
    add_column :trust_attack_month_report_actions, :owner_latitude, :float
    add_column :trust_attack_month_report_actions, :owner_longitude, :float
    add_column :trust_attack_month_report_actions, :content, :string
    add_column :trust_attack_month_report_actions, :approach_date, :date
    add_column :trust_attack_month_report_actions, :approach_kind_id, :integer
    add_column :trust_attack_month_report_actions, :approach_kind_code, :string
    add_column :trust_attack_month_report_actions, :approach_kind_name, :string
    add_column :trust_attack_month_report_actions, :delete_flg, :boolean, :default=>false
  end
end
