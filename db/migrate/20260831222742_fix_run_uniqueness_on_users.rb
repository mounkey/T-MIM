class FixRunUniquenessOnUsers < ActiveRecord::Migration[8.2]
  def up
    remove_index :users, :run
    add_index :users, [:run, :account_id], unique: true
  end

  def down
    remove_index :users, [:run, :account_id]
    add_index :users, :run, unique: true
  end
end
