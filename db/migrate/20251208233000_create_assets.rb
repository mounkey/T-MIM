class CreateAssets < ActiveRecord::Migration[8.2]
  def change
    create_table :assets, id: :uuid do |t|
      t.string :name
      t.text :description
      t.integer :year
      t.string :serial_number
      t.string :make
      t.string :model
      t.string :plate
      t.integer :odometer
      t.references :asset_category, type: :uuid, null: false, foreign_key: true
      t.references :tag, type: :uuid, null: false, foreign_key: true
      t.integer :status
      t.string :location

      t.timestamps
    end
  end
end
