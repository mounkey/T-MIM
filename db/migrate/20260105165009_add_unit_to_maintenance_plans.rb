class AddUnitToMaintenancePlans < ActiveRecord::Migration[8.2]
  def change
    add_column :maintenance_plans, :unit, :string unless column_exists?(:maintenance_plans, :unit)
    add_column :maintenance_plans, :frequency, :integer unless column_exists?(:maintenance_plans, :frequency)
    add_column :maintenance_plans, :name, :string unless column_exists?(:maintenance_plans, :name)
  end
end
