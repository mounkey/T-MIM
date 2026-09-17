class Superadmin::InvoicesController < Superadmin::BaseController
  before_action :set_invoice, only: %i[ show edit update destroy ]

  # GET /superadmin/invoices or /superadmin/invoices.json
  def index
    @invoices = Invoice.all
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
        format.html { redirect_to [:superadmin, @invoice], notice: "Invoice was successfully created." }
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
        format.html { redirect_to [:superadmin, @invoice], notice: "Invoice was successfully updated.", status: :see_other }
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
      format.html { redirect_to superadmin_invoices_path, notice: "Invoice was successfully destroyed.", status: :see_other }
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
      params.fetch(:invoice, {})
    end
end
