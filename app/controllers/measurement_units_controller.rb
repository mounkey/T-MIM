class MeasurementUnitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_measurement_unit, only: %i[edit update destroy]

  def index
    if current_user.account && MeasurementUnit.count.zero?
      MeasurementUnit.seed_defaults_for_account!(current_user.account)
    end
    @units = MeasurementUnit.all.order(:name).page(params[:page]).per(20)
  end

  def new
    @unit = MeasurementUnit.new
  end

  def edit
  end

  def create
    @unit = MeasurementUnit.new(measurement_unit_params)

    if @unit.save
      redirect_to measurement_units_path, notice: "Unidad de medida creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @unit.update(measurement_unit_params)
      redirect_to measurement_units_path, notice: "Unidad de medida actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @unit.destroy
    redirect_to measurement_units_path, notice: "Unidad de medida eliminada exitosamente.", status: :see_other
  end

  private

  def set_measurement_unit
    @unit = MeasurementUnit.find(params[:id])
  end

  def measurement_unit_params
    params.require(:measurement_unit).permit(:name, :abbreviation, :description)
  end
end
