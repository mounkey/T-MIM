class CreateMaintenancePlans < ActiveRecord::Migration[8.2]
  def change
    create_table :maintenance_plans, id: :uuid, if_not_exists: true do |t|
      t.references :sub_component, type: :uuid, null: false, foreign_key: true
      t.string :name
      t.integer :frequency
      t.string :unit

      t.timestamps
    end
  end
end
