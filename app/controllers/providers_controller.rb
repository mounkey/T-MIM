class ProvidersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_provider, only: %i[ edit update destroy ]

  def index
    @providers = Provider.includes(:tags, :region, :city).all.order(:name).page(params[:page]).per(20)
  end

  def new
    @provider = Provider.new
  end

  def edit
  end

  def create
    @provider = Provider.new(provider_params)

    if @provider.save
      redirect_to providers_path, notice: "Proveedor creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @provider.update(provider_params)
      redirect_to providers_path, notice: "Proveedor actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @provider.destroy
    redirect_to providers_path, notice: "Proveedor eliminado exitosamente.", status: :see_other
  end

  private

  def set_provider
    @provider = Provider.find(params[:id])
  end

  def provider_params
    params.require(:provider).permit(
      :name, :rut, :contact_name, :phone, :email, :address,
      :region_id, :city_id, :description, :rating, :active, :website,
      tag_ids: []
    )
  end
end
