class CreateCities < ActiveRecord::Migration[7.1]
  def change
    create_table :cities, id: :uuid do |t|
      t.string :name
      t.references :region, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
