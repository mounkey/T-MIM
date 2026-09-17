class CreateComponents < ActiveRecord::Migration[8.2]
  def change
    create_table :components, id: :uuid do |t|
      t.string :name
      t.references :asset_category, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
