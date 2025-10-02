class Suppliers::ServicesController < ApplicationController
  before_action :set_service, only: %i[show edit update]
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
      redirect_to users_service_path(@service)
    else
      render :new, status: :unprocessable_entity
    end

  def edit
  end

  def update
    if @service.update(service_params)
      redirect_to users_service_path(@service)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:category, :sub_category, :description, :price, :published)
  end

end
