class AddFlowGatewayConfigurationToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :flow_integration_mode, :string, default: "delegated", null: false
    add_column :accounts, :custom_flow_api_key, :string
    add_column :accounts, :custom_flow_secret_key, :string
  end
end
