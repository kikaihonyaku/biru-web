class TrustAttackMonthReport < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :trust_attack_month_report_actions
end
