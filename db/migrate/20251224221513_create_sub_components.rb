class CreateSubComponents < ActiveRecord::Migration[8.2]
  def change
    create_table :sub_components, id: :uuid do |t|
      t.string :name
      t.references :component, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
