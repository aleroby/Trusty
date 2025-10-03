class OrdersController < ApplicationController
  before_action :set_service, only: [:update, :create]

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user
    @order.service_id = @service.id
    @order.service_address = current_user.address
    date = params[:order][:date].split("-")
    @order.total_price = params[:order][:total_cents].to_i
    @order.start_date_time = Time.new(date[0], date[1], date[2], params[:order][:start_time].to_i)
    @order.end_date_time = Time.new(date[0], date[1], date[2], params[:order][:end_time].to_i)
    @order.status = "Pendiente"
    if @order.save
      redirect_to dashboard_index_path
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
    @service = Service.first
    # @service = Service.find(params[:service_id])
  end

  def order_params
    params.require(:order).permit(:start_date_time, :end_date_time )
  end
end
