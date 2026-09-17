class CreateInvoices < ActiveRecord::Migration[8.2]
  def change
    create_table :invoices, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.decimal :amount
      t.string :status
      t.date :due_date
      t.datetime :paid_at

      t.timestamps
    end
  end
end
