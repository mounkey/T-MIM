class CreateWarehouseCategoriesAndMeasurementUnits < ActiveRecord::Migration[8.2]
  def change
    create_table :warehouse_categories, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :icon

      t.timestamps
    end
    add_index :warehouse_categories, [:name, :account_id], unique: true

    create_table :measurement_units, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :abbreviation, null: false
      t.text :description

      t.timestamps
    end
    add_index :measurement_units, [:name, :account_id], unique: true
  end
end
