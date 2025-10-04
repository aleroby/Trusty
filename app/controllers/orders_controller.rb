class OrdersController < ApplicationController
  before_action :set_service, only: [:update]

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    raise
    @order.user = current_user
    @order.service_id = params[:order][:service_id]
    @order.service_address = current_user.address
    @date = params[:order][:date]
    @order.start_time = params[:order][:start_time]
    @order.end_time = params[:order][:end_time]
    @order.total_price = params[:order][:total_price].to_i / 100
    @order.status = "Pendiente"
    if @order.save
      redirect_to dashboard_index_path
    else
      render services/show, status: :unprocessable_entity
    end
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    @order.user = @current_user
    @order.service = @service
    if @order.update(order_params)
        redirect_to new_order_path(@order)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def set_service
    @service = Service.find(params[:service_id])
  end

  def order_params
    params.require(:order).permit(:date, :start_time, :end_time, :total_price, :service_id)
  end
end
