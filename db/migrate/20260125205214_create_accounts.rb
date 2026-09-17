class CreateAccounts < ActiveRecord::Migration[8.2]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :name
      t.string :subdomain
      t.boolean :active

      t.timestamps
    end
  end
end
