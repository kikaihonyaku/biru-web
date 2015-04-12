class CreateTrustRewindings < ActiveRecord::Migration
  def change
    create_table :trust_rewindings do |t|
      t.string :trust_code
      t.integer :status, :default=>0
      t.timestamps
    end
  end
end
