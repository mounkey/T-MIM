class AddIconToAssetCategories < ActiveRecord::Migration[8.2]
  def change
    add_column :asset_categories, :icon, :string
  end
end
