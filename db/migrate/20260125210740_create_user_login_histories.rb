class CreateUserLoginHistories < ActiveRecord::Migration[8.2]
  def change
    create_table :user_login_histories, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.datetime :sign_in_at
      t.datetime :sign_out_at
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
