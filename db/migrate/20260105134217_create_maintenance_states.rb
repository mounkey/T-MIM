class CreateMaintenanceStates < ActiveRecord::Migration[8.2]
  def change
    create_table :maintenance_states, id: :uuid, if_not_exists: true do |t|
      t.references :asset, type: :uuid, null: false, foreign_key: true
      t.references :maintenance_plan, type: :uuid, null: false, foreign_key: true
      t.decimal :last_performed_value, precision: 12, scale: 2
      t.datetime :last_performed_at

      t.timestamps
    end
  end
end
