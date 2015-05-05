class AddTrustPlanSuggestion < ActiveRecord::Migration
  def change
    add_column :biru_user_monthlies, :trust_plan_suggestion, :integer
  end
end
