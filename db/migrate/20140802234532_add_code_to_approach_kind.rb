class AddCodeToApproachKind < ActiveRecord::Migration
  def change
    add_column :approach_kinds, :code, :string
  end
end
