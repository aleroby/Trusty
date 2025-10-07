# app/helpers/orders_helper.rb
module OrdersHelper
  def human_order_status(order)
    I18n.t("orders.status.#{order.status}")
  end
end
