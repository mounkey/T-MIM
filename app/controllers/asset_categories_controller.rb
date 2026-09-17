class AssetCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_asset_category, only: %i[ edit update destroy ]

  def index
    @asset_categories = AssetCategory.all.order(:name).page(params[:page]).per(20)
  end

  def new
    @asset_category = AssetCategory.new
  end

  def edit
  end

  def create
    @asset_category = AssetCategory.new(asset_category_params)

    if @asset_category.save
      @asset_categories = AssetCategory.all.order(:name).page(params[:page]).per(20)
      flash.now[:notice] = "Categoría creada exitosamente."

      respond_to do |format|
        format.html { redirect_to asset_categories_path, notice: "Categoría creada exitosamente." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @asset_category.update(asset_category_params)
      @asset_categories = AssetCategory.all.order(:name).page(params[:page]).per(20)
      flash.now[:notice] = "Categoría actualizada exitosamente."

      respond_to do |format|
        format.html { redirect_to asset_categories_path, notice: "Categoría actualizada exitosamente." }
        format.turbo_stream { render :create }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @asset_category = AssetCategory.includes(components: { sub_components: :maintenance_plans }).find(params[:id])
    @assets = @asset_category.assets.includes(:tag, :maintenance_states).order(created_at: :desc)

    if params[:query].present?
      q = "%#{params[:query]}%"
      @assets = @assets.where("name ILIKE ? OR serial_number ILIKE ? OR plate ILIKE ?", q, q, q)
    end

    # Prepare Hierarchy Data for View (Table Structure)
    # { asset_id => { component_name => [ { plan, status } ] } }
    @hierarchy = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } }
    @asset_alerts = Hash.new { |h, k| h[k] = { red: 0, orange: 0, yellow: 0 } }

    @assets.each do |asset|
      @asset_category.components.each do |component|
        component.sub_components.each do |sub_component|
          sub_component.maintenance_plans.each do |plan|

            # 1. Try to find cached state
            state = asset.maintenance_states.find { |s| s.maintenance_plan_id == plan.id }

            status = if state && state.current_status.present?
              {
                status: state.current_status.to_sym,
                percentage: state.percentage_used || 0.0,
                target: state.next_due_at ? "Vence: #{state.next_due_at.strftime("%d/%m/%Y")}" : "Calculando...",
                color_class: case state.current_status.to_sym
                             when :red then 'bg-danger'
                             when :orange then 'bg-orange'
                             when :yellow then 'bg-warning'
                             else 'bg-success'
                             end,
                details: "Estado Guardado"
              }
            else
              # 2. Fallback to calculation
              MaintenanceStatusService.new(asset, plan).calculate
            end

            # Build Task Object
            task = {
              id: "#{asset.id}-#{plan.id}",
              plan: plan,
              status_details: status
            }

            @hierarchy[asset.id][component.name] << task

            # Update Alert Counters
            if status[:status] != :white
              @asset_alerts[asset.id][status[:status]] += 1
            end
          end
        end
      end
    end
  end

  def destroy
    @asset_category.destroy
    redirect_to asset_categories_path, notice: "Categoría eliminada exitosamente.", status: :see_other
  end

  private
    def set_asset_category
      @asset_category = AssetCategory.find(params[:id])
    end

    def asset_category_params
      params.require(:asset_category).permit(:name, :description, :icon,
        components_attributes: [:id, :name, :_destroy,
          sub_components_attributes: [:id, :name, :_destroy]
        ],
        maintenance_plans_attributes: [:id, :name, :frequency, :unit, :sub_component_id, :details, :_destroy]
      )
    end
end
