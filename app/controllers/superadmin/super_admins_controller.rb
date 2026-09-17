class Superadmin::SuperAdminsController < Superadmin::BaseController
  before_action :set_super_admin, only: %i[ show edit update destroy ]

  # GET /superadmin/super_admins or /superadmin/super_admins.json
  def index
    @super_admins = SuperAdmin.all
  end

  # GET /superadmin/super_admins/1 or /superadmin/super_admins/1.json
  def show
  end

  # GET /superadmin/super_admins/new
  def new
    @super_admin = SuperAdmin.new
  end

  # GET /superadmin/super_admins/1/edit
  def edit
  end

  # POST /superadmin/super_admins or /superadmin/super_admins.json
  def create
    @super_admin = SuperAdmin.new(super_admin_params)

    respond_to do |format|
      if @super_admin.save
        format.html { redirect_to superadmin_super_admins_path, notice: "Super admin was successfully created." }
        format.json { render :show, status: :created, location: @super_admin }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @super_admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /superadmin/super_admins/1 or /superadmin/super_admins/1.json
  def update
    p = super_admin_params
    if p[:password].blank?
      p.delete(:password)
      p.delete(:password_confirmation)
    end

    respond_to do |format|
      if @super_admin.update(p)
        format.html { redirect_to superadmin_super_admins_path, notice: "Super admin was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @super_admin }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @super_admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /superadmin/super_admins/1 or /superadmin/super_admins/1.json
  def destroy
    @super_admin.destroy!

    respond_to do |format|
      format.html { redirect_to superadmin_super_admins_path, notice: "Super admin was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_super_admin
      @super_admin = SuperAdmin.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def super_admin_params
      params.require(:super_admin).permit(:nombre, :email, :telefono, :region_id, :city_id, :password, :password_confirmation)
    end
end
