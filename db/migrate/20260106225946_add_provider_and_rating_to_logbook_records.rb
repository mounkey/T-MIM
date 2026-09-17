class AddProviderAndRatingToLogbookRecords < ActiveRecord::Migration[8.2]
  def change
    add_reference :logbook_records, :provider, type: :uuid, null: true, foreign_key: true
    add_column :logbook_records, :provider_rating, :integer
  end
end
