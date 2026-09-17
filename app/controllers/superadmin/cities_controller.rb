class Superadmin::CitiesController < Superadmin::BaseController
  before_action :set_city, only: %i[ show edit update destroy ]

  # GET /superadmin/cities or /superadmin/cities.json
  def index
    @cities = City.all
  end

  # GET /superadmin/cities/1 or /superadmin/cities/1.json
  def show
  end

  # GET /superadmin/cities/new
  def new
    @city = City.new
  end

  # GET /superadmin/cities/1/edit
  def edit
  end

  # POST /superadmin/cities or /superadmin/cities.json
  def create
    @city = City.new(city_params)

    respond_to do |format|
      if @city.save
        format.html { redirect_to superadmin_cities_path, notice: "City was successfully created." }
        format.json { render :show, status: :created, location: @city }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /superadmin/cities/1 or /superadmin/cities/1.json
  def update
    respond_to do |format|
      if @city.update(city_params)
        format.html { redirect_to superadmin_cities_path, notice: "City was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @city }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /superadmin/cities/1 or /superadmin/cities/1.json
  def destroy
    @city.destroy!

    respond_to do |format|
      format.html { redirect_to superadmin_cities_path, notice: "City was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_city
      @city = City.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def city_params
      params.fetch(:city, {})
    end
end
