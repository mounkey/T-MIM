class AssetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_asset, only: %i[show edit update destroy]

  def index
    @assets = Asset.all.order(created_at: :desc)

    # Filter logic
    if params[:query].present?
      @assets = @assets.where("name ILIKE :q OR make ILIKE :q OR model ILIKE :q OR plate ILIKE :q OR serial_number ILIKE :q", q: "%#{params[:query]}%")
    end

    if params[:asset_category_id].present?
      @assets = @assets.where(asset_category_id: params[:asset_category_id])
    end

    if params[:tag_id].present?
      @assets = @assets.where(tag_id: params[:tag_id])
    end

    if params[:make].present?
      @assets = @assets.where("make ILIKE ?", "%#{params[:make]}%")
    end

    @assets = @assets.page(params[:page])
  end

  def show
    # History Tab
    @logbook_records = @asset.logbook_records.includes(:user, :provider).order(recorded_at: :desc)

    # Suggested Providers Tab (Match by Asset Tags)
    # Assuming Providers have many Tags and we match if the Provider has the Asset's Tag
    @suggested_providers = Provider.joins(:tags).where(tags: { id: @asset.tag_id }).distinct

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: "assets/show_pdf", layout: "pdf", formats: [:html]).force_encoding("UTF-8")
        pdf = Grover.new(html, display_url: request.base_url).to_pdf
        send_data pdf, filename: "historial_#{@asset.plate}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def new
    @asset = Asset.new
  end

  def edit
  end

  def create
    @asset = Asset.new(asset_params)

    if @asset.save
      redirect_to asset_path(@asset), notice: "Maquinaria creada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @asset.update(asset_params)
      redirect_to asset_path(@asset), notice: "Maquinaria actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @asset.destroy
    redirect_to assets_path, notice: "Maquinaria eliminada correctamente.", status: :see_other
  end

  private

  def set_asset
    @asset = Asset.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(:name, :description, :make, :model, :year, :serial_number, :plate, :location, :status, :asset_category_id, :tag_id)
  end
end
