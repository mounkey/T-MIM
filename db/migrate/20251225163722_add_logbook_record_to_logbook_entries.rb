class AddLogbookRecordToLogbookEntries < ActiveRecord::Migration[8.2]
  def change
    add_reference :logbook_entries, :logbook_record, type: :uuid, null: true, foreign_key: true
  end
end
