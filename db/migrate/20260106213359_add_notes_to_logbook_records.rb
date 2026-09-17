class AddNotesToLogbookRecords < ActiveRecord::Migration[8.2]
  def change
    add_column :logbook_records, :notes, :text
  end
end
