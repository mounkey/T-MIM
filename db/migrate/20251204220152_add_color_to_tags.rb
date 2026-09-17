class AddColorToTags < ActiveRecord::Migration[8.2]
  def change
    add_column :tags, :color, :string, default: "#6c757d"
  end
end
