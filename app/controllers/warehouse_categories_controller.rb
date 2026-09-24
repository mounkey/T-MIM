class WarehouseCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_warehouse_category, only: %i[edit update destroy]

  def index
    if current_user.account && WarehouseCategory.count.zero?
      WarehouseCategory.seed_defaults_for_account!(current_user.account)
    end
    @categories = WarehouseCategory.all.order(:name).page(params[:page]).per(20)
  end

  def new
    @category = WarehouseCategory.new
  end

  def edit
  end

  def create
    @category = WarehouseCategory.new(warehouse_category_params)

    if @category.save
      redirect_to warehouse_categories_path, notice: "Categoría de bodega creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(warehouse_category_params)
      redirect_to warehouse_categories_path, notice: "Categoría de bodega actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to warehouse_categories_path, notice: "Categoría de bodega eliminada exitosamente.", status: :see_other
  end

  private

  def set_warehouse_category
    @category = WarehouseCategory.find(params[:id])
  end

  def warehouse_category_params
    params.require(:warehouse_category).permit(:name, :description, :icon)
  end
end
