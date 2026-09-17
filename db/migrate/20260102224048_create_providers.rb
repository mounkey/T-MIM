class CreateProviders < ActiveRecord::Migration[8.2]
  def change
    create_table :providers, id: :uuid do |t|
      t.string :name
      t.string :rut
      t.string :contact_name
      t.string :phone
      t.string :email
      t.string :address
      t.references :region, type: :uuid, null: false, foreign_key: true
      t.references :city, type: :uuid, null: false, foreign_key: true
      t.text :description
      t.integer :rating
      t.boolean :active
      t.string :website

      t.timestamps
    end
  end
end
