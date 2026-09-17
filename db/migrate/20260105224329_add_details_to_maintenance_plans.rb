class AddDetailsToMaintenancePlans < ActiveRecord::Migration[8.2]
  def change
    unless column_exists?(:maintenance_plans, :details)
      add_column :maintenance_plans, :details, :text
    end

    unless column_exists?(:maintenance_plans, :scenario)
      add_column :maintenance_plans, :scenario, :integer
    end

    unless column_exists?(:maintenance_plans, :asset_category_id)
      add_reference :maintenance_plans, :asset_category, type: :uuid, null: true, foreign_key: true
    end
  end
end
