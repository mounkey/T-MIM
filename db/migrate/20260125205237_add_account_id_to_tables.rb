class AddAccountIdToTables < ActiveRecord::Migration[8.2]
  def up
    # 1. Add column (nullable first)
    tables = [:users, :assets, :asset_categories, :providers, :logbook_records]

    tables.each do |table|
      add_reference table, :account, type: :uuid, index: true
    end

    # 2. Create Default Account
    # We use raw SQL to avoid model validations during migration
    execute "INSERT INTO accounts (name, subdomain, active, created_at, updated_at) VALUES ('MIM Default', 'default', true, NOW(), NOW())"
    default_account_id = connection.select_value("SELECT id FROM accounts WHERE subdomain = 'default'")

    # 3. Backfill Data (Assign existing records to default account)
    tables.each do |table|
      execute "UPDATE #{table} SET account_id = '#{default_account_id}'"
    end

    # 4. Add Not Null Constraint
    tables.each do |table|
      change_column_null table, :account_id, false
    end
  end

  def down
    tables = [:users, :assets, :asset_categories, :providers, :logbook_records]

    tables.each do |table|
      remove_reference table, :account
    end
  end
end
