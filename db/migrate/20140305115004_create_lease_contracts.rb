class CreateLeaseContracts < ActiveRecord::Migration
  def change
    create_table :lease_contracts do |t|
      t.string :code
      t.string :start_date
      t.string :leave_date
      t.integer :building_id
      t.integer :room_id
      t.integer :lease_month
      t.integer :rent
      t.timestamps
    end
  end
end
