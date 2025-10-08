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

    @supplier = @service.user

    # Promedio global del proveedor (lo que recibe en cualquier servicio)
    @supplier_avg   = (@supplier.supplier_rating_avg || 0).round(1)
    @supplier_count = @supplier.supplier_reviews_count

    # Reviews solo de este servicio dirigidas al proveedor
    @service_supplier_reviews = @service.supplier_reviews
                                      .includes(:client)
                                      .order(created_at: :desc)
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
