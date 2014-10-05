class AddProprietaryCompanyToImpTables < ActiveRecord::Migration
  def change
    add_column :imp_tables, :proprietary_company, :string
    add_column :buildings, :proprietary_company, :string
  end
end
