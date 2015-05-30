class AddNextStartDateToDataUpadteTimes < ActiveRecord::Migration
  def change
    add_column :data_update_times, :next_start_date, :date
  end
end
