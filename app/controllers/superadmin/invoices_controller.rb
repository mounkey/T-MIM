class Superadmin::InvoicesController < Superadmin::BaseController
  before_action :set_invoice, only: %i[ show edit update destroy ]

  # GET /superadmin/invoices or /superadmin/invoices.json
  def index
    @active_tab = params[:tab].presence || "sales" # sales (ventas/suscripciones), remittances (remesas/cierres), flow (pasarela)
    @invoices = Invoice.includes(:account).order(created_at: :desc)
    @remittances = RemittanceBatch.recent rescue []
    @settings = SystemSetting.all.index_by(&:key) rescue {}

    # KPIs de Ventas y Finanzas
    @total_paid_invoices = @invoices.where("LOWER(status) IN ('pagado', 'paid')").count
    @total_pending_invoices = @invoices.where.not("LOWER(status) IN ('pagado', 'paid')").count
    @total_revenue = @invoices.where("LOWER(status) IN ('pagado', 'paid')").sum(:amount)
  end

  # GET /superadmin/invoices/1 or /superadmin/invoices/1.json
  def show
  end

  # GET /superadmin/invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /superadmin/invoices/1/edit
  def edit
  end

  # POST /superadmin/invoices or /superadmin/invoices.json
  def create
    @invoice = Invoice.new(invoice_params)

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to superadmin_invoices_path(tab: "sales"), notice: "Pago de suscripción registrado con éxito." }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /superadmin/invoices/1 or /superadmin/invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to superadmin_invoices_path(tab: "sales"), notice: "Registro de suscripción actualizado.", status: :see_other }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /superadmin/invoices/1 or /superadmin/invoices/1.json
  def destroy
    @invoice.destroy!

    respond_to do |format|
      format.html { redirect_to superadmin_invoices_path(tab: "sales"), notice: "Registro eliminado.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def invoice_params
      params.fetch(:invoice, {}).permit(:account_id, :amount, :due_date, :paid_at, :status)
    end
end
