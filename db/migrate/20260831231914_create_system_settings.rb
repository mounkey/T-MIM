class CreateSystemSettings < ActiveRecord::Migration[8.2]
  def change
    create_table :system_settings, id: :uuid do |t|
      t.string :key
      t.text :value
      t.string :description

      t.timestamps
    end
    add_index :system_settings, :key, unique: true
  end
end
