class AddCommercialPlansAndContractFieldsToAccounts < ActiveRecord::Migration[8.2]
  def change
    add_column :accounts, :plan_type, :string, default: "inicial", null: false
    add_column :accounts, :monthly_price_uf, :decimal, precision: 6, scale: 2, default: 0.5, null: false
    add_column :accounts, :max_assets_limit, :integer, default: 50, null: false
    add_column :accounts, :billing_cycle, :string, default: "monthly", null: false # monthly / annual
    add_column :accounts, :billing_mode, :string, default: "flow", null: false # flow / transfer
    add_column :accounts, :contract_status, :string, default: "pending_activation" # pending_activation / active / suspended
    add_column :accounts, :giro, :string
    add_column :accounts, :legal_representative_name, :string
    add_column :accounts, :legal_representative_rut, :string
    add_column :accounts, :invitation_token, :string
    add_column :accounts, :invitation_sent_at, :datetime
    add_column :accounts, :invitation_expires_at, :datetime
    add_column :accounts, :contract_accepted_at, :datetime
    add_column :accounts, :contract_accepted_ip, :string
    add_column :accounts, :contract_accepted_by_rut, :string
    add_column :accounts, :contract_version, :string, default: "v1.0-2026"

    add_index :accounts, :invitation_token, unique: true
    add_index :accounts, :plan_type
    add_index :accounts, :contract_status
  end
end
