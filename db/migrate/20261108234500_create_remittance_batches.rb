class CreateRemittanceBatches < ActiveRecord::Migration[8.0]
  def change
    create_table :remittance_batches, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :batch_code, null: false # Ej: "REM-TMIM-2026-11"
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.decimal :total_amount_uf, precision: 10, scale: 2, default: 0.0
      t.integer :total_amount_clp, default: 0
      t.integer :invoices_count, default: 0
      t.string :status, default: "cerrado" # abierto, cerrado, auditado
      t.text :notes

      t.timestamps
    end
    add_index :remittance_batches, :batch_code, unique: true
  end
end
