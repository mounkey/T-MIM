class AddCachingColumnsToMaintenanceStates < ActiveRecord::Migration[8.2]
  def change
    add_column :maintenance_states, :current_status, :integer
    add_column :maintenance_states, :next_due_at, :date
    add_column :maintenance_states, :percentage_used, :decimal
  end
end
