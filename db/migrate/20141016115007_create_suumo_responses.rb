class CreateSuumoResponses < ActiveRecord::Migration
  def change
    create_table :suumo_responses do |t|
    	t.integer :yyyymm
    	t.integer :week_idx
			t.integer :renters_room_id
			t.string  :renters_room_cd
			t.integer :public_days # ŒfÚ“ú”
			t.integer :view_list_summary
			t.integer :view_list_daily
			t.integer :view_detail_summary
			t.integer :view_detail_daily
			t.integer :inquery_visite_reserve
			t.integer :inquery_summary
			t.string :suumary_start_day
			t.string :summary_end_day
      t.timestamps
    end
  end
end
