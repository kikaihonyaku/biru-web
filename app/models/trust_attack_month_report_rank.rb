class TrustAttackMonthReportRank < ActiveRecord::Base
  # attr_accessible :title, :body

  default_scope where(:delete_flg => false)

  belongs_to :attack_state_last_month, :class_name => 'AttackState'
  belongs_to :attack_state_this_month, :class_name => 'AttackState'
  belongs_to :building
  belongs_to :owner
  belongs_to :trust_attack_month_report

end
