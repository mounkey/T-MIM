class CreateSettlements < ActiveRecord::Migration[8.2]
  def change
    create_table :settlements, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.date :period_start, null: false
      t.date :period_end, null: false
      
      t.decimal :total_collected, precision: 12, scale: 2, default: 0.0, null: false # Bruto Flow
      t.decimal :total_gateway_fees, precision: 12, scale: 2, default: 0.0, null: false # Costo Flow
      t.decimal :total_platform_fees, precision: 12, scale: 2, default: 0.0, null: false # Ganancia T-MIM
      t.decimal :net_payout, precision: 12, scale: 2, default: 0.0, null: false # A transferir al taller

      t.integer :status, default: 0, null: false # 0: pending, 1: paid, 2: canceled
      t.datetime :transferred_at
      t.string :transfer_reference
      t.text :bank_details_snapshot
      t.text :notes

      t.timestamps
    end

    add_index :settlements, [:account_id, :period_start, :period_end]
    add_index :settlements, :status

    # Agregar campos bancarios a accounts si no existen
    change_table :accounts, bulk: true do |t|
      t.string :bank_name
      t.string :bank_account_type
      t.string :bank_account_number
      t.string :bank_account_holder_name
      t.string :bank_account_holder_rut
    end

    # Vincular cada pago de Flow a una liquidación cuando se corte
    add_reference :payments, :settlement, type: :uuid, foreign_key: true
  end
end
