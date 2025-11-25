class ServicesController < ApplicationController
  skip_before_action :authenticate_user!

  # def index
  #   # Se añade condición para filtrar por categoria
  #   if params[:category].present?
  #     @services = Service.where(category: params[:category], published: true)
  #     @pagy, @services = pagy(@services, items: 9)

  #   elsif params[:query].present?
  #     multisearch_results = PgSearch.multisearch(params[:query])
  #     @services = multisearch_results
  #                      .where(searchable_type: "Service")
  #                      .map(&:searchable)

  #     @services = @services.select { |service| service&.published? }

  #     # @pagy, @services = pagy(@services)
  #     @pagy, @services = pagy_array(@services, items: 9)

  #   elsif params[:mode] == "filtros"
  #     @services = Service.filter(params).where(published: true)

  #     @pagy, @services = pagy(@services, items: 9)

  #     # AGREGADO PARA QUE FUNCIONE EL BUCADOR DEL BANNER
  #     # if @services.is_a?(ActiveRecord::Relation)
  #     #   @pagy, @services = pagy(@services, items: 9)
  #     # else
  #     #   @pagy, @services = pagy_array(@services, items: 9)
  #     # end
  #     #
  #   else
  #     @services = Service.where(published: true)
  #     @pagy, @services = pagy(@services, items: 9)
  #   end
  # end

  def index
    # 1️⃣ Filtros avanzados SIEMPRE primero
    if params[:mode] == "filtros"
      @services = Service.filter(params)

      @pagy, @services = pagy(@services, items: 9)
      return
    end

    # 2️⃣ Búsqueda
    if params[:query].present?
      multisearch_results = PgSearch.multisearch(params[:query])
      @services = multisearch_results
                    .where(searchable_type: "Service")
                    .map(&:searchable)
                    .select { |s| s&.published? }

      @pagy, @services = pagy_array(@services, items: 9)
      return
    end

    # 3️⃣ Sólo categoría (si no se usó el sistema de filtros)
    if params[:category].present?
      @services = Service.where(category: params[:category], published: true)
      @pagy, @services = pagy(@services, items: 9)
      return
    end

    # 4️⃣ Default
    @services = Service.where(published: true)
    @pagy, @services = pagy(@services, items: 9)
  end

  def show
    @order = Order.new
    @service = Service.find(params[:id])

    @supplier = @service.user

    # Promedio global de reviews del servicio
    scope = Review.for_this_service_supplier(@service.id)
    @supplier_avg = (scope.average(:rating) || 0).round(2)
    @supplier_count = scope.count

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
