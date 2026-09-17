class RegionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_region, only: %i[ edit update destroy ]

  def index
    @regions = Region.all.order(:name).page(params[:page]).per(20)
  end

  def new
    @region = Region.new
  end

  def edit
  end

  def create
    @region = Region.new(region_params)

    if @region.save
      @regions = Region.all.order(:name).page(params[:page]).per(20)
      flash.now[:notice] = "Región creada exitosamente."

      respond_to do |format|
        format.html { redirect_to regions_path, notice: "Región creada exitosamente." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @region.update(region_params)
      @regions = Region.all.order(:name).page(params[:page]).per(20)
      flash.now[:notice] = "Región actualizada exitosamente."

      respond_to do |format|
        format.html { redirect_to regions_path, notice: "Región actualizada exitosamente." }
        format.turbo_stream { render :create }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @region.destroy
    redirect_to regions_path, notice: "Región eliminada exitosamente.", status: :see_other
  end

  private
    def set_region
      @region = Region.find(params[:id])
    end

    def region_params
      params.require(:region).permit(:name, :code)
    end
end
