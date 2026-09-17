class AddAccountIdToSecondaryTables < ActiveRecord::Migration[8.0]
  def change
    add_reference :components, :account, type: :uuid, null: true, foreign_key: true
    add_reference :sub_components, :account, type: :uuid, null: true, foreign_key: true
    add_reference :maintenance_plans, :account, type: :uuid, null: true, foreign_key: true
    add_reference :maintenance_checks, :account, type: :uuid, null: true, foreign_key: true
    add_reference :maintenance_states, :account, type: :uuid, null: true, foreign_key: true
    add_reference :meters, :account, type: :uuid, null: true, foreign_key: true
    add_reference :logbook_entries, :account, type: :uuid, null: true, foreign_key: true
    add_reference :tags, :account, type: :uuid, null: true, foreign_key: true
  end
end
