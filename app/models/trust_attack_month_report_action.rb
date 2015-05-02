class TrustAttackMonthReportAction < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # belongs_to :owner
  # belongs_to :approach_kind
  # belongs_to :biru_user
  belongs_to :trust_attack_month_report
  belongs_to :owner_approach
  
end
