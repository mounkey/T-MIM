# This seed file creates a realistic dataset for stress testing and logic verification.
# Usage: bin/rails runner db/stress_seed.rb

Rails.logger = Logger.new(STDOUT)
Rails.logger.info "🌱 Starting Stress Seed..."

# 1. Clean previous data (optional, but good for idempotency if we want a fresh start)
# We won't destroy everything to avoid wiping production by mistake, but let's destroy
# all assets created by this seed if we tagged them? No, let's just create new ones.
# Or better: Destroy all non-admin users and assets if it's safe.
# For safety, let's just create data.

# Ensure Admin Exists
admin = User.find_or_create_by!(email: 'admin@mim.cl') do |u|
  u.name = 'Juan Pablo Grover'
  u.password = '123456'
  u.password_confirmation = '123456'
  u.role = :admin
  u.run = '11.111.111-1'
end
Rails.logger.info "✅ Admin: #{admin.email}"

# Ensure basic Master Data exists
region = Region.find_or_create_by!(code: 'RM') do |r|
  r.name = 'Metropolitana'
end
city = City.find_or_create_by!(name: 'Santiago') do |c|
  c.region = region
end
tag = Tag.find_or_create_by!(name: 'Operativo') do |t|
  t.color = '#198754'
end

# 2. Create Asset Categories with Hierarchy
categories = [
  { name: 'Excavadoras', icon: 'fa-tractor' },
  { name: 'Camiones Tolva', icon: 'fa-truck' },
  { name: 'Grúas', icon: 'fa-truck-pickup' },
  { name: 'Generadores', icon: 'fa-bolt' },
  { name: 'Compresores', icon: 'fa-wind' }
]

categories.each do |cat_data|
  category = AssetCategory.find_or_create_by!(name: cat_data[:name])
  category.update!(icon: cat_data[:icon], description: "Categoría de prueba")

  # Components
  ['Motor', 'Sistema Hidráulico', 'Sistema Eléctrico', 'Chasis'].each do |comp_name|
    component = category.components.find_or_create_by!(name: comp_name)

    # SubComponents
    ['Nivel A', 'Nivel B'].each do |sub_name|
      sub = component.sub_components.find_or_create_by!(name: "#{comp_name} - #{sub_name}")

      # Maintenance Plans
      # 1. Time based (e.g., Monthly Check)
      MaintenancePlan.find_or_create_by!(name: "Inspección Mensual #{comp_name}", sub_component: sub, asset_category: category) do |p|
        p.frequency = 1
        p.unit = 'Meses'
        p.details = "Revisar estado general de #{sub.name}"
      end

      # 2. Meter based (e.g., Oil Change every 1000 hours)
      MaintenancePlan.find_or_create_by!(name: "Cambio Aceite #{comp_name}", sub_component: sub, asset_category: category) do |p|
        p.frequency = 500
        p.unit = 'Horas' # Assuming meter unit is 'Horas'
        p.details = "Cambiar aceite y filtros"
      end
    end
  end
  Rails.logger.info "   📂 Category: #{category.name} ready."
end

# 3. Create Assets (20 per category = 100 total)
Rails.logger.info "🚜 Creating Assets and History..."

AssetCategory.all.each do |category|
  20.times do |i|
    asset_name = "#{category.name} ##{i + 1} - Seed"
    asset = Asset.find_or_initialize_by(name: asset_name)
    asset.assign_attributes(
      make: ['CAT', 'Komatsu', 'Volvo', 'John Deere'].sample,
      model: "X-#{rand(100..900)}",
      year: rand(2015..2024),
      serial_number: "SN-#{SecureRandom.hex(4).upcase}",
      plate: "AB-CD-#{rand(10..99)}",
      status: :operativa,
      asset_category: category,
      tag: tag
    )
    asset.save!

    # Ensure Meters exist
    hour_meter = asset.meters.find_or_create_by!(name: 'Horómetro', unit: 'Horas')
    km_meter = asset.meters.find_or_create_by!(name: 'Odómetro', unit: 'KM')

    # Simulate History: 6 months back to today
    # We want some assets to be RED (Critical), some ORANGE, some WHITE.

    current_hours = rand(100..2000)
    current_km = rand(1000..50000)

    # Set initial reading 6 months ago
    start_date = 6.months.ago

    # Create ~1 log per week
    (0..24).each do |week|
      date = start_date + week.weeks

      # Increase usage
      inc_hours = rand(10..50)
      inc_km = rand(100..500)

      # Sometimes we skip updates to simulate idle
      next if rand < 0.2

      # Create Logbook Record
      record = LogbookRecord.create!(
        asset: asset,
        user: admin,
        recorded_at: date,
        notes: "Visita semanal simulada"
      )

      # Update Meters (Logic inside LogbookEntry will update Meter model too)
      # We just set current value based on accumulation
      # Actually, we need to be careful. The logic uses previous value.
      # Simplified: Just update the meter directly to the final value at the end?
      # No, we want history entries.

      # We need to manually manage the accumulation for the loop
      # But since we are mocking, let's just create the entry.

      # Note: Asset meter needs to be updated progressively.
      # Let's just update the asset meter to the final value at the end of the loop.
    end

    # Update final meter values
    hour_meter.update!(current_value: current_hours)
    km_meter.update!(current_value: current_km)

    # RANDOMIZE MAINTENANCE STATE
    # To test the traffic lights, we need to simulate that maintenance WAS performed (or not).

    category.maintenance_plans.each do |plan|
      state = MaintenanceState.find_or_initialize_by(asset: asset, maintenance_plan: plan)

      # Scenario 1: Just done (White/Green)
      # Scenario 2: Done a while ago (Yellow/Orange)
      # Scenario 3: Never done (Red)

      scenario = rand(1..3)

      if scenario == 1 # Fresh
        state.last_performed_at = Time.current - 2.days
        state.last_performed_value = current_hours - 10 # Just 10 hours ago
      elsif scenario == 2 # Warning
        # If freq is 500h, we want usage around 400h (80%)
        usage_needed = plan.frequency * 0.8
        state.last_performed_at = Time.current - (plan.frequency * 0.8).to_i.days # Rough approx for time
        state.last_performed_value = [0, current_hours - usage_needed].max
      else # Critical (Never done or done long ago)
        # Default is nil (never done) which counts from creation.
        # But since we just created the asset today, "creation" is today, so time-based would be 0%.
        # To simulate "Old Asset, Never Maintained", we need to hack the creation date OR set a very old maintenance date.
        state.last_performed_at = 1.year.ago
        state.last_performed_value = 0
      end

      state.save!

      # Force update of cached columns (current_status, etc.)
      # This ensures the dashboard looks correct immediately after seeding
      MaintenanceStatusService.new(asset, plan).update_state!
    end
  end
end

Rails.logger.info "🎉 Stress Seed Completed Successfully!"
