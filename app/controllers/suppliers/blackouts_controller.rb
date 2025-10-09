# app/controllers/suppliers/blackouts_controller.rb
class Suppliers::BlackoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_supplier!

  def index
    @blackouts = current_user.blackouts.order(starts_at: :desc)
    @blackout  = current_user.blackouts.new
  end

  def create
    @blackout = current_user.blackouts.new(blackout_params)
    if @blackout.save
      redirect_to suppliers_availabilities_path, notice: "Bloqueo creado."
    else
      @blackouts = current_user.blackouts.order(starts_at: :desc)
      flash.now[:alert] = @blackout.errors.full_messages.to_sentence
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    blackout = current_user.blackouts.find(params[:id])
    blackout.destroy
    redirect_to suppliers_blackouts_path, notice: "Bloqueo eliminado."
  end

  private

  def blackout_params
    params.require(:blackout).permit(:starts_at, :ends_at, :reason)
  end

  def require_supplier!
    redirect_to root_path, alert: "Sólo proveedores." unless current_user.role == "supplier"
  end
end
