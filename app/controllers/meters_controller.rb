class MetersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_asset
  before_action :set_meter, only: %i[edit update destroy]

  def new
    @meter = @asset.meters.new
    # Render for modal
  end

  def edit
    # Render for modal
  end

  def create
    @meter = @asset.meters.new(meter_params)

    if @meter.save
      respond_to do |format|
        format.turbo_stream { render :create }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @meter.update(meter_params)
      respond_to do |format|
        format.turbo_stream { render :create }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meter.destroy
    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_asset
    @asset = Asset.find(params[:asset_id])
  end

  def set_meter
    @meter = @asset.meters.find(params[:id])
  end

  def meter_params
    params.require(:meter).permit(:name, :unit, :current_value)
  end
end
