# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.2].define(version: 2026_09_24_194500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active"
    t.string "bank_account_holder_name"
    t.string "bank_account_holder_rut"
    t.string "bank_account_number"
    t.string "bank_account_type"
    t.string "bank_name"
    t.uuid "city_id"
    t.string "contacto_cargo"
    t.string "contacto_email"
    t.string "contacto_nombre"
    t.string "contacto_rut"
    t.string "contacto_telefono"
    t.datetime "created_at", null: false
    t.string "direccion"
    t.string "email"
    t.string "name"
    t.string "nombre_fantasia"
    t.string "razon_social"
    t.uuid "region_id"
    t.string "rut"
    t.string "subdomain"
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_accounts_on_city_id"
    t.index ["region_id"], name: "index_accounts_on_region_id"
  end

  create_table "asset_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_asset_categories_on_account_id"
  end

  create_table "assets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "asset_category_id", null: false
    t.uuid "client_id"
    t.date "commission_date"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "location"
    t.string "make"
    t.string "model"
    t.string "name"
    t.string "plate"
    t.string "serial_number"
    t.integer "status"
    t.uuid "tag_id", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["account_id"], name: "index_assets_on_account_id"
    t.index ["asset_category_id"], name: "index_assets_on_asset_category_id"
    t.index ["client_id"], name: "index_assets_on_client_id"
    t.index ["tag_id"], name: "index_assets_on_tag_id"
  end

  create_table "cities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "region_id", null: false
    t.datetime "updated_at", null: false
    t.index ["region_id"], name: "index_cities_on_region_id"
  end

  create_table "clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "address"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.text "notes"
    t.string "phone"
    t.string "rut"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_clients_on_account_id"
    t.index ["rut", "account_id"], name: "index_clients_on_rut_and_account_id"
  end

  create_table "components", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.uuid "asset_category_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_components_on_account_id"
    t.index ["asset_category_id"], name: "index_components_on_asset_category_id"
  end

  create_table "invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.date "due_date"
    t.datetime "paid_at"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_invoices_on_account_id"
  end

  create_table "logbook_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.datetime "created_at", null: false
    t.decimal "current_value", precision: 12, scale: 2
    t.uuid "logbook_record_id"
    t.uuid "meter_id", null: false
    t.decimal "previous_value", precision: 12, scale: 2
    t.decimal "quantity", precision: 12, scale: 2
    t.text "remarks"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["account_id"], name: "index_logbook_entries_on_account_id"
    t.index ["logbook_record_id"], name: "index_logbook_entries_on_logbook_record_id"
    t.index ["meter_id"], name: "index_logbook_entries_on_meter_id"
    t.index ["user_id"], name: "index_logbook_entries_on_user_id"
  end

  create_table "logbook_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "asset_id", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.uuid "provider_id"
    t.integer "provider_rating"
    t.datetime "recorded_at"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["account_id"], name: "index_logbook_records_on_account_id"
    t.index ["asset_id"], name: "index_logbook_records_on_asset_id"
    t.index ["provider_id"], name: "index_logbook_records_on_provider_id"
    t.index ["user_id"], name: "index_logbook_records_on_user_id"
  end

  create_table "maintenance_checks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.uuid "component_id", null: false
    t.datetime "created_at", null: false
    t.uuid "logbook_record_id", null: false
    t.text "notes"
    t.integer "status"
    t.uuid "sub_component_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_maintenance_checks_on_account_id"
    t.index ["component_id"], name: "index_maintenance_checks_on_component_id"
    t.index ["logbook_record_id"], name: "index_maintenance_checks_on_logbook_record_id"
    t.index ["sub_component_id"], name: "index_maintenance_checks_on_sub_component_id"
  end

  create_table "maintenance_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.uuid "asset_category_id"
    t.datetime "created_at", null: false
    t.text "details"
    t.integer "frequency"
    t.string "name"
    t.uuid "sub_component_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_maintenance_plans_on_account_id"
    t.index ["asset_category_id"], name: "index_maintenance_plans_on_asset_category_id"
    t.index ["sub_component_id"], name: "index_maintenance_plans_on_sub_component_id"
  end

  create_table "maintenance_states", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.uuid "asset_id", null: false
    t.datetime "created_at", null: false
    t.integer "current_status"
    t.datetime "last_performed_at"
    t.decimal "last_performed_value", precision: 12, scale: 2
    t.uuid "maintenance_plan_id", null: false
    t.date "next_due_at"
    t.decimal "percentage_used"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_maintenance_states_on_account_id"
    t.index ["asset_id"], name: "index_maintenance_states_on_asset_id"
    t.index ["maintenance_plan_id"], name: "index_maintenance_states_on_maintenance_plan_id"
  end

  create_table "measurement_units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "abbreviation", null: false
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_measurement_units_on_account_id"
    t.index ["name", "account_id"], name: "index_measurement_units_on_name_and_account_id", unique: true
  end

  create_table "meters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.uuid "asset_id", null: false
    t.datetime "created_at", null: false
    t.decimal "current_value", precision: 12, scale: 2, default: "0.0"
    t.string "name"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_meters_on_account_id"
    t.index ["asset_id"], name: "index_meters_on_asset_id"
  end

  create_table "payment_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "asset_id"
    t.uuid "client_id"
    t.datetime "created_at", null: false
    t.decimal "discount_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.string "folio_number"
    t.decimal "labor_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.uuid "logbook_record_id"
    t.integer "mechanical_status", default: 0, null: false
    t.text "notes"
    t.decimal "parts_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.string "payment_token"
    t.decimal "total_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "folio_number"], name: "index_payment_orders_on_account_id_and_folio_number"
    t.index ["account_id", "mechanical_status"], name: "index_payment_orders_on_account_id_and_mechanical_status"
    t.index ["account_id"], name: "index_payment_orders_on_account_id"
    t.index ["asset_id"], name: "index_payment_orders_on_asset_id"
    t.index ["client_id"], name: "index_payment_orders_on_client_id"
    t.index ["logbook_record_id"], name: "index_payment_orders_on_logbook_record_id"
    t.index ["payment_token"], name: "index_payment_orders_on_payment_token", unique: true
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.decimal "flow_fee", precision: 12, scale: 2, default: "0.0", null: false
    t.string "flow_order_id"
    t.decimal "net_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.string "notes"
    t.integer "payment_channel", default: 0, null: false
    t.uuid "payment_order_id", null: false
    t.decimal "platform_fee", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "recorded_at", null: false
    t.uuid "settlement_id"
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["account_id", "payment_channel"], name: "index_payments_on_account_id_and_payment_channel"
    t.index ["account_id", "recorded_at"], name: "index_payments_on_account_id_and_recorded_at"
    t.index ["account_id"], name: "index_payments_on_account_id"
    t.index ["payment_order_id"], name: "index_payments_on_payment_order_id"
    t.index ["settlement_id"], name: "index_payments_on_settlement_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.boolean "active"
    t.string "address"
    t.uuid "city_id", null: false
    t.string "contact_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.string "name"
    t.string "phone"
    t.integer "rating"
    t.uuid "region_id", null: false
    t.string "rut"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["account_id"], name: "index_providers_on_account_id"
    t.index ["city_id"], name: "index_providers_on_city_id"
    t.index ["region_id"], name: "index_providers_on_region_id"
  end

  create_table "providers_tags", id: false, force: :cascade do |t|
    t.uuid "provider_id", null: false
    t.uuid "tag_id", null: false
  end

  create_table "regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "settlements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.text "bank_details_snapshot"
    t.datetime "created_at", null: false
    t.decimal "net_payout", precision: 12, scale: 2, default: "0.0", null: false
    t.text "notes"
    t.date "period_end", null: false
    t.date "period_start", null: false
    t.integer "status", default: 0, null: false
    t.decimal "total_collected", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_gateway_fees", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_platform_fees", precision: 12, scale: 2, default: "0.0", null: false
    t.string "transfer_reference"
    t.datetime "transferred_at"
    t.datetime "updated_at", null: false
    t.index ["account_id", "period_start", "period_end"], name: "idx_on_account_id_period_start_period_end_4fc5ff3bdc"
    t.index ["account_id"], name: "index_settlements_on_account_id"
    t.index ["status"], name: "index_settlements_on_status"
  end

  create_table "stock_movements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "asset_id"
    t.datetime "created_at", null: false
    t.uuid "logbook_record_id"
    t.integer "movement_type", default: 0, null: false
    t.text "notes"
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.uuid "warehouse_item_id", null: false
    t.index ["account_id"], name: "index_stock_movements_on_account_id"
    t.index ["asset_id"], name: "index_stock_movements_on_asset_id"
    t.index ["logbook_record_id"], name: "index_stock_movements_on_logbook_record_id"
    t.index ["movement_type"], name: "index_stock_movements_on_movement_type"
    t.index ["user_id"], name: "index_stock_movements_on_user_id"
    t.index ["warehouse_item_id"], name: "index_stock_movements_on_warehouse_item_id"
  end

  create_table "sub_components", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.uuid "component_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sub_components_on_account_id"
    t.index ["component_id"], name: "index_sub_components_on_component_id"
  end

  create_table "super_admins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "city_id"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "nombre"
    t.uuid "region_id"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "telefono"
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_super_admins_on_city_id"
    t.index ["email"], name: "index_super_admins_on_email", unique: true
    t.index ["region_id"], name: "index_super_admins_on_region_id"
    t.index ["reset_password_token"], name: "index_super_admins_on_reset_password_token", unique: true
  end

  create_table "system_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "key"
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["key"], name: "index_system_settings_on_key", unique: true
  end

  create_table "tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.string "color", default: "#6c757d"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_tags_on_account_id"
  end

  create_table "user_login_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "sign_in_at"
    t.datetime "sign_out_at"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["account_id"], name: "index_user_login_histories_on_account_id"
    t.index ["user_id"], name: "index_user_login_histories_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0
    t.string "run", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email", "account_id"], name: "index_users_on_email_and_account_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["run", "account_id"], name: "index_users_on_run_and_account_id", unique: true
  end

  create_table "warehouse_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_warehouse_categories_on_account_id"
    t.index ["name", "account_id"], name: "index_warehouse_categories_on_name_and_account_id", unique: true
  end

  create_table "warehouse_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "category", default: "General"
    t.decimal "cost_price", precision: 12, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "location"
    t.decimal "minimum_stock", precision: 10, scale: 2, default: "2.0", null: false
    t.string "name", null: false
    t.decimal "reserved_quantity", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "sale_price", precision: 12, scale: 2, default: "0.0"
    t.string "sku"
    t.decimal "stock_quantity", precision: 10, scale: 2, default: "0.0", null: false
    t.string "unit", default: "Unidad"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_warehouse_items_on_account_id"
    t.index ["name", "account_id"], name: "index_warehouse_items_on_name_and_account_id"
    t.index ["sku", "account_id"], name: "index_warehouse_items_on_sku_and_account_id"
  end

  add_foreign_key "accounts", "cities"
  add_foreign_key "accounts", "regions"
  add_foreign_key "assets", "asset_categories"
  add_foreign_key "assets", "clients"
  add_foreign_key "assets", "tags"
  add_foreign_key "cities", "regions"
  add_foreign_key "clients", "accounts"
  add_foreign_key "components", "accounts"
  add_foreign_key "components", "asset_categories"
  add_foreign_key "invoices", "accounts"
  add_foreign_key "logbook_entries", "accounts"
  add_foreign_key "logbook_entries", "logbook_records"
  add_foreign_key "logbook_entries", "meters"
  add_foreign_key "logbook_entries", "users"
  add_foreign_key "logbook_records", "assets"
  add_foreign_key "logbook_records", "providers"
  add_foreign_key "logbook_records", "users"
  add_foreign_key "maintenance_checks", "accounts"
  add_foreign_key "maintenance_checks", "components"
  add_foreign_key "maintenance_checks", "logbook_records"
  add_foreign_key "maintenance_checks", "sub_components"
  add_foreign_key "maintenance_plans", "accounts"
  add_foreign_key "maintenance_plans", "asset_categories"
  add_foreign_key "maintenance_plans", "sub_components"
  add_foreign_key "maintenance_states", "accounts"
  add_foreign_key "maintenance_states", "assets"
  add_foreign_key "maintenance_states", "maintenance_plans"
  add_foreign_key "measurement_units", "accounts"
  add_foreign_key "meters", "accounts"
  add_foreign_key "meters", "assets"
  add_foreign_key "payment_orders", "accounts"
  add_foreign_key "payment_orders", "assets"
  add_foreign_key "payment_orders", "clients"
  add_foreign_key "payment_orders", "logbook_records"
  add_foreign_key "payments", "accounts"
  add_foreign_key "payments", "payment_orders"
  add_foreign_key "payments", "settlements"
  add_foreign_key "payments", "users"
  add_foreign_key "providers", "cities"
  add_foreign_key "providers", "regions"
  add_foreign_key "settlements", "accounts"
  add_foreign_key "stock_movements", "accounts"
  add_foreign_key "stock_movements", "assets"
  add_foreign_key "stock_movements", "logbook_records"
  add_foreign_key "stock_movements", "users"
  add_foreign_key "stock_movements", "warehouse_items"
  add_foreign_key "sub_components", "accounts"
  add_foreign_key "sub_components", "components"
  add_foreign_key "super_admins", "cities"
  add_foreign_key "super_admins", "regions"
  add_foreign_key "tags", "accounts"
  add_foreign_key "user_login_histories", "accounts"
  add_foreign_key "user_login_histories", "users"
  add_foreign_key "warehouse_categories", "accounts"
  add_foreign_key "warehouse_items", "accounts"
end
