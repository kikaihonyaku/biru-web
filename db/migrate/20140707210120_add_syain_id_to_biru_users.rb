class AddSyainIdToBiruUsers < ActiveRecord::Migration
  def change
    add_column :biru_users, :syain_id, :string
  end
end
