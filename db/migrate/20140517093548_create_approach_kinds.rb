class CreateApproachKinds < ActiveRecord::Migration
  def change
    create_table :approach_kinds do |t|
      t.string :name
    end
  end
end
