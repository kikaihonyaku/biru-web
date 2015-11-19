class AddColumnSortNumToDepts < ActiveRecord::Migration
  def change
  	add_column :depts, :sort_num, :integer
  end
end
