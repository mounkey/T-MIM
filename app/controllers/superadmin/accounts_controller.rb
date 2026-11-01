class Superadmin::AccountsController < Superadmin::BaseController
  before_action :set_account, only: %i[ show edit update destroy ]

  # GET /superadmin/accounts or /superadmin/accounts.json
  def index
    @accounts = Account.all
    if params[:plan_type].present?
      @accounts = @accounts.where(plan_type: params[:plan_type])
    end
    if params[:billing_mode].present?
      @accounts = @accounts.where(billing_mode: params[:billing_mode])
    end
    if params[:status].present?
      @accounts = params[:status] == "active" ? @accounts.where(active: true) : @accounts.where(active: false)
    end
    @accounts = @accounts.order(created_at: :desc)
  end

  # GET /superadmin/accounts/1 or /superadmin/accounts/1.json
  def show
  end

  # GET /superadmin/accounts/new
  def new
    @account = Account.new
  end

  # GET /superadmin/accounts/1/edit
  def edit
  end

  # POST /superadmin/accounts or /superadmin/accounts.json
  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to [:superadmin, @account], notice: "Account was successfully created." }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /superadmin/accounts/1 or /superadmin/accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to [:superadmin, @account], notice: "Account was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /superadmin/accounts/1 or /superadmin/accounts/1.json
  def destroy
    @account.destroy!

    respond_to do |format|
      format.html { redirect_to superadmin_accounts_path, notice: "Account was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

    def toggle_status
    @account = Account.find(params[:id])
    @account.update_column(:active, !@account.active)
    redirect_back fallback_location: superadmin_accounts_path, notice: "Estado de empresa #{@account.name} actualizado."
  end

  def add_quota_package
    @account = Account.find(params[:id])
    amount = params[:amount].to_i
    amount = 20 if amount <= 0

    @account.increment!(:extra_assets_quota, amount)
    redirect_back fallback_location: superadmin_accounts_path, notice: "Se agregaron +#{amount} vehículos de cupo extra a #{@account.name}. Límite total actual: #{@account.effective_assets_limit} vehículos."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.require(:account).permit(
        :name, :razon_social, :nombre_fantasia, :rut, :email, :direccion, :region_id, :city_id,
        :contacto_nombre, :contacto_rut, :contacto_cargo, :contacto_email, :contacto_telefono,
        :subdomain, :active,
        :plan_type, :monthly_price_uf, :max_assets_limit, :billing_cycle, :billing_mode,
        :giro, :legal_representative_name, :legal_representative_rut, :contract_status,
        :flow_integration_mode, :custom_flow_api_key, :custom_flow_secret_key,
        :extra_assets_quota
      )
    end
end
