class TrustAttackMonthReportAction < ActiveRecord::Base
  # attr_accessible :title, :body
  
  default_scope where(:delete_flg => false)
  
  belongs_to :owner
  belongs_to :approach_kind
  belongs_to :trust_attack_month_report
  belongs_to :owner_approach
  
end
