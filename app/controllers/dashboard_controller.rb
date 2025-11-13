class DashboardController < ApplicationController
   def index
    if params[:pending].present?
      @orders = current_user.orders.where(status: "confirmed")
    elsif params[:history].present?
      @orders = current_user.orders.where(status: ["completed", "canceled"])
    else
      @orders = current_user.orders
    end

    @client = current_user

    # Promedio global del proveedor (lo que recibe en cualquier servicio)
    @client_avg   = (@client.client_rating_avg || 0).round(2)
    @client_count = @client.client_reviews_count

  end
end
