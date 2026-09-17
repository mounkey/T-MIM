class CreateLogbookEntries < ActiveRecord::Migration[8.2]
  def change
    create_table :logbook_entries, id: :uuid do |t|
      t.references :meter, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.decimal :previous_value, precision: 12, scale: 2
      t.decimal :current_value, precision: 12, scale: 2
      t.decimal :quantity, precision: 12, scale: 2
      t.text :remarks

      t.timestamps
    end
  end
end
