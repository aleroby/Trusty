class ServicesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if params[:query].present?
      multisearch_results = PgSearch.multisearch(params[:query])
      @services = multisearch_results
                       .where(searchable_type: "Service")
                       .map(&:searchable)
      @pagy, @services = pagy(@services)
    elsif params[:mode] == "filtros"
      @services = Service.filter(params)
      @pagy, @services = pagy(@services)
    else
      @services = Service.all
      @pagy, @services = pagy(@services)
    end
  end

  def show
    @order = Order.new
    @service = Service.find(params[:id])
  end

  #------------------------BLOQUE PARA AGENDA PROVEEDOR------------------------

  def available_slots
    @service = Service.find(params[:id])
    date = Date.parse(params[:date])
    slots = @service.available_slots(date)

    render json: {
      date: date,
      duration_minutes: @service.duration_minutes,
      slots: slots.map { |t| t.strftime("%H:%M") } # ej: ["09:00", "09:30", ...]
    }
  rescue ArgumentError
    render json: { error: "Fecha inválida" }, status: :unprocessable_entity
  end

end
