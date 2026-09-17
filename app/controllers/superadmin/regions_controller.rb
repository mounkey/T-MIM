class Superadmin::RegionsController < Superadmin::BaseController
  before_action :set_region, only: %i[ show edit update destroy ]

  # GET /superadmin/regions or /superadmin/regions.json
  def index
    @regions = Region.all
  end

  # GET /superadmin/regions/1 or /superadmin/regions/1.json
  def show
  end

  # GET /superadmin/regions/new
  def new
    @region = Region.new
  end

  # GET /superadmin/regions/1/edit
  def edit
  end

  # POST /superadmin/regions or /superadmin/regions.json
  def create
    @region = Region.new(region_params)

    respond_to do |format|
      if @region.save
        format.html { redirect_to superadmin_regions_path, notice: "Region was successfully created." }
        format.json { render :show, status: :created, location: @region }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /superadmin/regions/1 or /superadmin/regions/1.json
  def update
    respond_to do |format|
      if @region.update(region_params)
        format.html { redirect_to superadmin_regions_path, notice: "Region was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @region }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /superadmin/regions/1 or /superadmin/regions/1.json
  def destroy
    @region.destroy!

    respond_to do |format|
      format.html { redirect_to superadmin_regions_path, notice: "Region was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_region
      @region = Region.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def region_params
      params.fetch(:region, {})
    end
end
