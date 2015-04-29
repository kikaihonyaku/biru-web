class AddSequenceToApproachKinds < ActiveRecord::Migration
  def change
    add_column :approach_kinds, :sequence, :integer
  end
end
