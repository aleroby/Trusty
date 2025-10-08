require "test_helper"

class Suppliers::OrdersControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def index
    if params[:pending].present?
      # Solo órdenes de servicios del proveedor actual y con status "confirmed"
      @orders = Order.joins(:service)
                     .where(services: { user_id: current_user.id })
                     .where(status: "confirmed")
    else
      @orders = Order.joins(:service)
                     .where(services: { user_id: current_user.id })
    end
  end
end
