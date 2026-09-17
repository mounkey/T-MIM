class Superadmin::AccountsController < Superadmin::BaseController
  before_action :set_account, only: %i[ show edit update destroy ]

  # GET /superadmin/accounts or /superadmin/accounts.json
  def index
    @accounts = Account.all
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.fetch(:account, {})
    end
end
