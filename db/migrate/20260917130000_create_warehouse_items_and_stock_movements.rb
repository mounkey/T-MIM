class CreateWarehouseItemsAndStockMovements < ActiveRecord::Migration[8.2]
  def change
    create_table :warehouse_items, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :sku
      t.string :category, default: "General"
      t.string :unit, default: "Unidad"
      t.decimal :stock_quantity, precision: 10, scale: 2, default: 0.0, null: false
      t.decimal :reserved_quantity, precision: 10, scale: 2, default: 0.0, null: false
      t.decimal :minimum_stock, precision: 10, scale: 2, default: 2.0, null: false
      t.decimal :cost_price, precision: 12, scale: 2, default: 0.0
      t.decimal :sale_price, precision: 12, scale: 2, default: 0.0
      t.string :location
      t.text :description

      t.timestamps
    end

    add_index :warehouse_items, [:sku, :account_id]
    add_index :warehouse_items, [:name, :account_id]

    create_table :stock_movements, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :warehouse_item, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :asset, type: :uuid, null: true, foreign_key: true
      t.references :logbook_record, type: :uuid, null: true, foreign_key: true
      t.integer :movement_type, default: 0, null: false # 0: entry, 1: exit, 2: reserve, 3: release, 4: adjustment
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.text :notes

      t.timestamps
    end

    add_index :stock_movements, :movement_type
  end
end
