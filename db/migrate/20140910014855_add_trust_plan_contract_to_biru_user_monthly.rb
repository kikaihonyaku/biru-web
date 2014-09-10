class AddTrustPlanContractToBiruUserMonthly < ActiveRecord::Migration
  def change
    add_column :biru_user_monthlies, :trust_plan_contract, :integer
    
    add_column :trust_attack_state_histories, :room_num, :integer
    add_column :trust_attack_state_histories, :trust_oneself, :boolean, :default=>false # 自社・他社区分
    add_column :trust_attack_state_histories, :manage_type_id, :integer
    
  end
end
