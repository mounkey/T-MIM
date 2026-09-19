class CreatePaymentOrdersAndPayments < ActiveRecord::Migration[8.2]
  def change
    create_table :payment_orders, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :logbook_record, type: :uuid, foreign_key: true
      t.references :client, type: :uuid, foreign_key: true
      t.references :asset, type: :uuid, foreign_key: true

      t.string :folio_number
      t.integer :mechanical_status, default: 0, null: false # 0: diagnosis, 1: in_progress, 2: completed, 3: delivered
      t.decimal :labor_amount, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :parts_amount, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :discount_amount, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :total_amount, precision: 12, scale: 2, default: 0.0, null: false

      t.string :payment_token, index: { unique: true }
      t.text :notes

      t.timestamps
    end

    add_index :payment_orders, [:account_id, :folio_number]
    add_index :payment_orders, [:account_id, :mechanical_status]

    create_table :payments, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :payment_order, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, foreign_key: true

      t.decimal :amount, precision: 12, scale: 2, null: false
      t.integer :payment_channel, default: 0, null: false # 0: cash, 1: pos_local, 2: transfer_local, 3: flow_online
      t.string :flow_order_id
      t.decimal :flow_fee, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :platform_fee, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :net_amount, precision: 12, scale: 2, default: 0.0, null: false

      t.datetime :recorded_at, null: false
      t.string :notes

      t.timestamps
    end

    add_index :payments, [:account_id, :payment_channel]
    add_index :payments, [:account_id, :recorded_at]
  end
end
