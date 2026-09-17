class WarehouseItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_warehouse_item, only: %i[ show edit update destroy add_stock ]

  def index
    @warehouse_items = WarehouseItem.all.order(:name)

    if params[:query].present?
      @warehouse_items = @warehouse_items.where("name ILIKE :q OR sku ILIKE :q OR location ILIKE :q", q: "%#{params[:query]}%")
    end

    if params[:category].present?
      @warehouse_items = @warehouse_items.where(category: params[:category])
    end

    @total_items = @warehouse_items.count
    @low_stock_items = @warehouse_items.select(&:low_stock?).count
    @warehouse_items = @warehouse_items.page(params[:page]).per(20)
  end

  def show
    @stock_movements = @warehouse_item.stock_movements.includes(:user, :asset).order(created_at: :desc).page(params[:page]).per(15)
  end

  def new
    @warehouse_item = WarehouseItem.new
  end

  def edit
  end

  def create
    @warehouse_item = WarehouseItem.new(warehouse_item_params)

    if @warehouse_item.save
      redirect_to warehouse_items_path, notice: "Repuesto/Insumo creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @warehouse_item.update(warehouse_item_params)
      redirect_to warehouse_items_path, notice: "Repuesto/Insumo actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @warehouse_item.destroy
    redirect_to warehouse_items_path, notice: "Repuesto/Insumo eliminado exitosamente.", status: :see_other
  end

  # Acción rápida para registrar ingreso de stock
  def add_stock
    quantity = params[:quantity].to_f
    notes = params[:notes].presence || "Ingreso manual de stock"

    if quantity > 0
      StockMovement.create!(
        account: current_account,
        warehouse_item: @warehouse_item,
        user: current_user,
        movement_type: :entry,
        quantity: quantity,
        notes: notes
      )
      redirect_to warehouse_item_path(@warehouse_item), notice: "Se ingresaron #{quantity} #{@warehouse_item.unit} a la bodega."
    else
      redirect_to warehouse_item_path(@warehouse_item), alert: "La cantidad debe ser mayor a 0."
    end
  end

  private

  def set_warehouse_item
    @warehouse_item = WarehouseItem.find(params[:id])
  end

  def warehouse_item_params
    params.require(:warehouse_item).permit(
      :name, :sku, :category, :unit, :stock_quantity,
      :minimum_stock, :cost_price, :sale_price, :location, :description
    )
  end
end
