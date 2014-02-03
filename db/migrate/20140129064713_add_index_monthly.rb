class AddIndexMonthly < ActiveRecord::Migration
  def change
    add_index "monthly_statements", ["dept_id"], :name=>"index_monthly_dept"
    add_index "monthly_statements", ["item_id"], :name=>"index_monthly_item"
    add_index "monthly_statements", ["yyyymm"], :name=>"index_monthly_yyyymm"

    add_index "monthly_statements", ["dept_id", "item_id", "yyyymm" ], :name=>"index_monthly_all"

  end
end
