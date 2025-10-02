class OrdersController < ApplicationController
  before_action :set_service, only: [:update, :create]

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    @order.user = @current_user
    @order.service = @service
    @order.total_price = @service.price * (end_date_time - start_date_time).to_i
    if @order.save
      redirect_to new_order_path(@order)
    else
      render :new, status: :unprocessable_entity
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
    params.require(:order).permit(:start_date_time, :service_address, :end_date_time, :status )
  end
end
