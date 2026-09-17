# scripts/verify_logic.rb
ActiveRecord::Base.transaction do
  puts "1. Creating Category..."
  cat = AssetCategory.create!(name: "Test Cat", description: "Test Desc", icon: "fa-truck")

  puts "2. Creating Component Structure..."
  comp = cat.components.create!(name: "Engine")
  sub = comp.sub_components.create!(name: "Filter")

  puts "3. Creating Plan..."
  plan = MaintenancePlan.create!(
    name: "Change Filter",
    frequency: 100,
    unit: "Horas",
    sub_component: sub,
    asset_category: cat,
    details: "Do it now"
  )

  puts "4. Creating Asset..."
  asset = Asset.create!(
    name: "Truck 01",
    asset_category: cat,
    status: :operativa,
    tag: Tag.first_or_create!(name: "TestTag", color: "#000")
  )

  puts "5. Creating Meter..."
  # Corrected: Meters belongs_to Asset and has a Unit, doesn't seem to validate name based on previous errors, but check model if needed.
  # The error said "Name can't be blank" - wait, Meter model? Or Asset?
  # Asset validates name. Meter?
  # Let's check Meter model.
  # Ah, Meter usually doesn't have a name, just unit and value.
  # Wait, the error stack trace was inside `asset.meters.create!`.
  # Maybe Meter validates name?

  meter = asset.meters.create!(unit: "Horas", current_value: 50, name: "Horometro")

  puts "6. Running Service..."
  service = MaintenanceStatusService.new(asset, plan)
  result = service.calculate

  puts "RESULT: #{result[:percentage]}% (Expected 50%)"
  puts "DETAILS: #{result[:details]}"

  puts "7. Checking Controller Logic..."

  found_plans = 0
  asset.asset_category.components.each do |c|
    c.sub_components.each do |s|
      s.maintenance_plans.each do |p|
        found_plans += 1
        puts "  Found Plan: #{p.name} (SubComp: #{p.sub_component.name})"
      end
    end
  end
  puts "Controller Loop Found: #{found_plans} plans"

  raise ActiveRecord::Rollback # Clean up
end
