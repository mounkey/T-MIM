class AddDetailsToSuperAdmins < ActiveRecord::Migration[8.2]
  def change
    add_column :super_admins, :nombre, :string
    add_column :super_admins, :telefono, :string
    add_reference :super_admins, :region, null: true, foreign_key: true, type: :uuid
    add_reference :super_admins, :city, null: true, foreign_key: true, type: :uuid
  end
end
