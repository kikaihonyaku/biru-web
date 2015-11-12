class CreateSelectivelyPostcodes < ActiveRecord::Migration
  def change
    create_table :selectively_postcodes do |t|
      t.string :postcode 
      t.timestamps
    end
  end
end
