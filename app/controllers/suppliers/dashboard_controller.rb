class Suppliers::DashboardController < ApplicationController
   def index
    if params[:pending].present?
      @orders = current_user.orders.where(status: "confirmed")
    elsif params[:history].present?
      @orders = current_user.orders.where(status: ["completed", "canceled"])
    else
      @orders = current_user.orders
    end
  end
end
