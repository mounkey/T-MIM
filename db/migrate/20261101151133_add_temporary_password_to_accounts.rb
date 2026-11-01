class AddTemporaryPasswordToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :temporary_password, :string
  end
end
