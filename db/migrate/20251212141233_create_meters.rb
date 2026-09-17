class CreateMeters < ActiveRecord::Migration[8.2]
  def change
    create_table :meters, id: :uuid do |t|
      t.references :asset, type: :uuid, null: false, foreign_key: true
      t.string :name
      t.string :unit
      t.decimal :current_value, precision: 12, scale: 2, default: 0

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO meters (asset_id, name, unit, current_value, created_at, updated_at)
          SELECT id, 'Odómetro', 'KM', CAST(odometer AS DECIMAL), NOW(), NOW()
          FROM assets
          WHERE odometer IS NOT NULL AND odometer > 0;
        SQL
      end
    end

    remove_column :assets, :odometer, :integer
  end
end
