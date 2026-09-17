require "test_helper"

class Superadmin::InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invoice = invoices(:one)
  end

  test "should get index" do
    get superadmin_invoices_url
    assert_response :success
  end

  test "should get new" do
    get new_superadmin_invoice_url
    assert_response :success
  end

  test "should create invoice" do
    assert_difference("Invoice.count") do
      post superadmin_invoices_url, params: { invoice: {} }
    end

    assert_redirected_to superadmin_invoice_url(Invoice.last)
  end

  test "should show invoice" do
    get superadmin_invoice_url(@invoice)
    assert_response :success
  end

  test "should get edit" do
    get edit_superadmin_invoice_url(@invoice)
    assert_response :success
  end

  test "should update invoice" do
    patch superadmin_invoice_url(@invoice), params: { invoice: {} }
    assert_redirected_to superadmin_invoice_url(@invoice)
  end

  test "should destroy invoice" do
    assert_difference("Invoice.count", -1) do
      delete superadmin_invoice_url(@invoice)
    end

    assert_redirected_to superadmin_invoices_url
  end
end
