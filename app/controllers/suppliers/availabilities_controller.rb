# app/controllers/suppliers/availabilities_controller.rb
class Suppliers::AvailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_supplier!

  def index
    @availabilities = current_user.availabilities.order(:wday, :start_time)
    @availability   = current_user.availabilities.new
  end

  def create
    @availability = current_user.availabilities.new(availability_params)
    if @availability.save
      redirect_to suppliers_availabilities_path, notice: "Franja agregada."
    else
      @availabilities = current_user.availabilities.order(:wday, :start_time)
      flash.now[:alert] = @availability.errors.full_messages.to_sentence
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    availability = current_user.availabilities.find(params[:id])
    availability.destroy
    redirect_to suppliers_availabilities_path, notice: "Franja eliminada."
  end

  private

  def availability_params
    params.require(:availability).permit(:wday, :start_time, :end_time)
  end

  def require_supplier!
    redirect_to root_path, alert: "Sólo proveedores." unless current_user.role == "supplier"
  end
end
