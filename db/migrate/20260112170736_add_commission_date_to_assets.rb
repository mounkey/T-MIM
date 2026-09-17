class AddCommissionDateToAssets < ActiveRecord::Migration[8.2]
  def change
    add_column :assets, :commission_date, :date
  end
end
