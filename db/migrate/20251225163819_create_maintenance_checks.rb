class CreateMaintenanceChecks < ActiveRecord::Migration[8.2]
  def change
    create_table :maintenance_checks, id: :uuid do |t|
      t.references :logbook_record, type: :uuid, null: false, foreign_key: true
      t.references :component, type: :uuid, null: false, foreign_key: true
      t.references :sub_component, type: :uuid, null: false, foreign_key: true
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
