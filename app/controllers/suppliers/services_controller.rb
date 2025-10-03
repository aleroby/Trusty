class Suppliers::ServicesController < ApplicationController
  before_action :set_service, only: %i[show edit update destroy]
  def index
    @services = current_user.services
  end

  def show
  end

  def new
    @service = Service.new
  end

  def create
    @service = Service.new(service_params)
    @service.user = current_user
    if @service.save
      redirect_to suppliers_dashboard_index_path, notice: "Servicio creado con éxito."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @service.update(service_params)
      redirect_to suppliers_dashboard_index_path, notice: "Servicio actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service.destroy
    redirect_to suppliers_services_path, notice: "Servicio eliminado."
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:category, :sub_category, :description, :price, :published, images: [])
  end

end
