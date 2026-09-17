class CitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_city, only: %i[ edit update destroy ]

  def index
    if params[:region_id]
      @cities = City.where(region_id: params[:region_id]).order(:name)
    else
      @cities = City.includes(:region).all.order(:name).page(params[:page]).per(20)
    end
  end

  def new
    @city = City.new
  end

  def edit
  end

  def create
    @city = City.new(city_params)

    if @city.save
      @cities = City.includes(:region).all.order(:name).page(params[:page]).per(20)
      flash.now[:notice] = "Ciudad creada exitosamente."

      respond_to do |format|
        format.html { redirect_to cities_path, notice: "Ciudad creada exitosamente." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @city.update(city_params)
      @cities = City.includes(:region).all.order(:name).page(params[:page]).per(20)
      flash.now[:notice] = "Ciudad actualizada exitosamente."

      respond_to do |format|
        format.html { redirect_to cities_path, notice: "Ciudad actualizada exitosamente." }
        format.turbo_stream { render :create }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @city.destroy
    redirect_to cities_path, notice: "Ciudad eliminada exitosamente.", status: :see_other
  end

  private
    def set_city
      @city = City.find(params[:id])
    end

    def city_params
      params.require(:city).permit(:name, :region_id)
    end
end
