class RemoveScenarioFromMaintenancePlans < ActiveRecord::Migration[8.2]
  def change
    remove_column :maintenance_plans, :scenario, :integer
  end
end
