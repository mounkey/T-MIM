class RemoveUniquenessFromUsersEmail < ActiveRecord::Migration[8.2]
  def up
    remove_index :users, :email
    add_index :users, [:email, :account_id], unique: true
  end

  def down
    remove_index :users, [:email, :account_id]
    add_index :users, :email, unique: true
  end
end
