class CreateLogbookRecords < ActiveRecord::Migration[8.2]
  def change
    create_table :logbook_records, id: :uuid do |t|
      t.references :asset, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
