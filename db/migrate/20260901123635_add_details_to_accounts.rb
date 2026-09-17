class AddDetailsToAccounts < ActiveRecord::Migration[8.2]
  def change
    add_column :accounts, :rut, :string
    add_column :accounts, :razon_social, :string
    add_column :accounts, :nombre_fantasia, :string
    add_column :accounts, :email, :string
    add_column :accounts, :direccion, :string
    add_reference :accounts, :region, null: true, foreign_key: true, type: :uuid
    add_reference :accounts, :city, null: true, foreign_key: true, type: :uuid
    add_column :accounts, :contacto_rut, :string
    add_column :accounts, :contacto_nombre, :string
    add_column :accounts, :contacto_cargo, :string
    add_column :accounts, :contacto_email, :string
    add_column :accounts, :contacto_telefono, :string
  end
end
