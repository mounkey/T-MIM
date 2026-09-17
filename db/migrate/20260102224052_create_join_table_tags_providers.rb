class CreateJoinTableTagsProviders < ActiveRecord::Migration[8.2]
  def change
    create_join_table :tags, :providers, column_options: { type: :uuid } do |t|
      # t.index [:tag_id, :provider_id]
      # t.index [:provider_id, :tag_id]
    end
  end
end
