class MaintenancePlansController < ApplicationController
  before_action :authenticate_user!

  def index
    # Fetch all plans with eager loading for the full hierarchy
    @maintenance_plans = MaintenancePlan.includes(sub_component: { component: :asset_category })
                                        .order("asset_categories.name", "components.name", "sub_components.name", :name)

    if params[:query].present?
      term = "%#{params[:query].downcase}%"
      @maintenance_plans = @maintenance_plans.references(:sub_component, :component, :asset_category)
                                             .where("maintenance_plans.name ILIKE ? OR sub_components.name ILIKE ? OR components.name ILIKE ? OR asset_categories.name ILIKE ?", term, term, term, term)
    end

    @maintenance_plans = @maintenance_plans.page(params[:page]).per(20)
  end

  def new
    @asset_categories = AssetCategory.order(:name)
    @maintenance_plan = MaintenancePlan.new
  end

  def create
    # "Wizard" Logic: Create component structure on the fly if requested
    if params[:new_component_name].present? || params[:new_sub_component_name].present?
      begin
        ActiveRecord::Base.transaction do
          # FIX: Extract category ID correctly (fallback to nested params if not at top level)
          category_id = params[:asset_category_id] || params[:maintenance_plan][:asset_category_id]
          category = AssetCategory.find(category_id)

          # 1. Resolve Component
          # Use hidden field ID unless "NEW" logic was triggered
          component = if params[:component_id].present?
                        Component.find(params[:component_id])
                      else
                        category.components.find_or_create_by!(name: params[:new_component_name])
                      end

          # 2. Resolve SubComponent
          # Use hidden field ID unless "NEW" logic was triggered
          sub_component = if params[:sub_component_id].present?
                            SubComponent.find(params[:sub_component_id])
                          else
                            component.sub_components.find_or_create_by!(name: params[:new_sub_component_name])
                          end

          # 3. Create Plan
          @maintenance_plan = sub_component.maintenance_plans.build(maintenance_plan_params)
          # Ensure asset_category_id is also set as it is required by schema/model validations often
          @maintenance_plan.asset_category = category

          @maintenance_plan.save!
        end
        redirect_to maintenance_plans_path, notice: "Plan de mantenimiento creado exitosamente."
      rescue ActiveRecord::RecordInvalid => e
        @error = e.message
        @asset_categories = AssetCategory.order(:name)
        @maintenance_plan ||= MaintenancePlan.new(maintenance_plan_params)
        render :new, status: :unprocessable_entity
      end
    else
      # Standard creation (if all IDs are passed)
      @maintenance_plan = MaintenancePlan.new(maintenance_plan_params)
      # We need to ensure asset_category_id is set if it's not in params but implied by sub_component
      if @maintenance_plan.sub_component
        @maintenance_plan.asset_category ||= @maintenance_plan.sub_component.component.asset_category
      end

      if @maintenance_plan.save
        redirect_to maintenance_plans_path, notice: "Plan de mantenimiento creado exitosamente."
      else
        @asset_categories = AssetCategory.order(:name)
        render :new, status: :unprocessable_entity
      end
    end
  end

  # API Endpoints for Stimulus Wizard
  def components
    category = AssetCategory.find(params[:asset_category_id])
    render json: category.components.select(:id, :name).order(:name)
  end

  def sub_components
    component = Component.find(params[:component_id])
    render json: component.sub_components.select(:id, :name).order(:name)
  end

  private

  def maintenance_plan_params
    params.require(:maintenance_plan).permit(:name, :frequency, :unit, :details, :sub_component_id, :asset_category_id)
  end
end
