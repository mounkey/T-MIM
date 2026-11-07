class CreateWikiArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :wiki_articles do |t|
      t.references :account, type: :uuid, foreign_key: true
      t.string :title, null: false
      t.string :category, default: "General"
      t.text :content, null: false
      t.boolean :is_global, default: false
      t.integer :position, default: 0
      t.string :icon, default: "fa-book"

      t.timestamps
    end

    add_index :wiki_articles, :category
    add_index :wiki_articles, :is_global
  end
end
