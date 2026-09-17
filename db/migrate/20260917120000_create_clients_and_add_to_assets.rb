class CreateClientsAndAddToAssets < ActiveRecord::Migration[8.2]
  def change
    create_table :clients, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :rut
      t.string :email
      t.string :phone
      t.string :address
      t.text :notes

      t.timestamps
    end

    add_index :clients, [:rut, :account_id]
    add_reference :assets, :client, type: :uuid, null: true, foreign_key: true
  end
end
