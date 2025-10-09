class OrdersController < ApplicationController
  #before_action :set_service, only: [:update]

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user
    @order.service_id = params[:order][:service_id]
    @order.service_address = current_user.address
    @date = params[:order][:date]
    @order.start_time = params[:order][:start_time]
    @order.end_time = params[:order][:end_time]
    @order.total_price = params[:order][:total_price].to_i / 100
    @order.status = "confirmed"
    if @order.save
      redirect_to dashboard_index_path
    else
      render dashboard_index_path, status: :unprocessable_entity
    end
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    update_params = order_status_params
    update_params[:date] = @order.date
    update_params[:start_time] = @order.start_time
    update_params[:end_time] = @order.end_time

    if @order.update(update_params)
      if @order.service.user == current_user
        redirect_to suppliers_orders_path(status: "confirmed"), notice: "Status actualizado correctamente."
      else
        redirect_to dashboard_index_path, notice: "Status actualizado correctamente."
      end
    else
      flash.now[:alert] = @order.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def set_service
    @service = Service.find(params[:service_id])
  end

  def order_status_params
    params.require(:order).permit(:status)
  end

  def order_params
    params.require(:order).permit(:date, :start_time, :end_time, :total_price, :service_id)
  end
end
