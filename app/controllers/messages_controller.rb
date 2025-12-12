class MessagesController < ApplicationController
  MAX_SERVICES = 10
  DISTANCE_THRESHOLD = 0.55 # ajusta si el ruido sigue

  def create
    @chat = Chat.find(params[:chat_id])
    client = @chat.user
    client_message = RubyLLM.embed(params[:message][:content])
    return render("/chats/show", status: :unprocessable_entity) if client_message&.vectors.blank?

    # services = Service.nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(MAX_SERVICES)
    services = fetch_relevant_services(client_message.vectors, client)

    instructions = build_instructions(services)

    @message = Message.new(message_params.merge(role: "user", chat_id: @chat.id))

    if @message.save
      update_chat_title_if_needed
      # Encola el streaming de la respuesta del asistente para no bloquear la petición HTTP
      AiStreamJob.perform_later(@chat.id, @message.id, instructions)
      redirect_to chat_path(@chat)
    else
      render "/chats/show", status: :unprocessable_entity
    end
  end

  private

  def fetch_relevant_services(query_vector, client) # query_vector es el client_message vectorizado
    available_services = Service.includes(:user, :supplier_reviews)
                   .where.not(embedding: nil)
                   .where(published: true)
    # filtro por radio del proveedor respecto del cliente, si hay lat/lon
    if client&.latitude && client&.longitude
      available_services = available_services.select do |service|
        supplier = service.user
        next if supplier.nil? || supplier.latitude.nil? || supplier.longitude.nil? || supplier.radius.nil?
        distance_client_supplier = Geocoder::Calculations.distance_between(
          [supplier.latitude, supplier.longitude],
          [client.latitude, client.longitude]
        )
        distance_client_supplier <= supplier.radius
      end
    else
      available_services = available_services.to_a
    end

    specific_services = Service.nearest_neighbors(:embedding, query_vector, distance: "cosine")
                       .first(MAX_SERVICES)

    # cruza vecinos con filtro de radio y descarta por umbral de distancia
    specific_services_ids = specific_services.select { |service| service.neighbor_distance && service.neighbor_distance <= DISTANCE_THRESHOLD }.map { |service| service.id }

    specific_services_ids = specific_services.map { |service| service.id } if specific_services_ids.empty? # fallback

    result = available_services.select { |service| specific_services_ids.include?(service.id) }

    # Rails.logger.info "available_services=#{available_services.size}"
    # Rails.logger.info "neighbors=#{specific_services.map { |s| [s.id, s.neighbor_distance] }}"
    # Rails.logger.info "chosen_ids=#{specific_services_ids}"

    result

  end

  def build_instructions(services)
    client_name = @chat.user&.first_name.to_s.strip.presence
    already_greeted = @chat.messages.where(role: "assistant").exists?

    context = services.map do |service|
      reviews = service.supplier_reviews.limit(3).map { |review| "#{review.rating}: #{review.content.to_s.truncate(140)}" }.join(" | ")
      service_info = []
      service_info << "SERVICE #{service.id}"
      service_info << "category: #{service.category}"
      service_info << "sub_category: #{service.sub_category}"
      service_info << "address: #{service.user&.address}"
      service_info << "lat: #{service.user&.latitude}, lon: #{service.user&.longitude}, radius_km: #{service.user&.radius}"
      service_info << "price: #{service.price}"
      service_info << "description: #{service.description.to_s.truncate(280)}"
      service_info << "reviews: #{reviews}"
      # Link directo al panel de detalles en la columna derecha del inbox IA
      service_info << "url: #{details_chat_url(@chat, service_id: service.id)}"
      service_info.join("\n")
    end.join("\n---\n")

    prompt = ""
      if already_greeted
        prompt += "No repitas el saludo con el #{client_name}. ; ve directo a la respuesta.\n\n"
      else
        prompt += "Hola #{client_name}! Estoy para ayudarte.\n\n"
        prompt += "El cliente se llama #{client_name}. Usa su nombre al saludar.\n\n"
      end
    prompt += system_prompt
    prompt += "\n\n"
    prompt += "Contexto de servicios (usa solo esto; si no alcanza, di que no hay servicios disponibles):\n"
    prompt += context

  end

  def system_prompt
    "Eres un asistente cálido y servicial en español para una app de servicios tipo Airbnb.
    Saluda al cliente por su nombre si lo conoces. Sé breve, amable y claro.

    Usa únicamente el contexto de servicios que te paso; no inventes datos ni URLs.
    # Si el contexto no alcanza, responde exactamente: \"No hay servicios disponibles para esta consulta\".

    Responde en Markdown, listando los mejores servicios priorizando rating y cercanía.
    Para cada servicio incluye: el nombre del proveedor, precio, y rating si hay, y la URL dada.

    Si el cliente te pregunta algo fuera de los servicios (small talk), responde cordialmente en pocas frases y avisa que tu especialidad son los servicios de Trusty.
    No cierres con preguntas genéricas (por ejemplo, '¿Quieres que te ayude a reservar?'); si ya diste opciones, termina con un cierre breve y concreto."
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def chat_title
    title_content = @chat.messages.first.content
    RubyLLM.chat.with_instructions("Genera un nombre descriptivo para un chat que no sea mas de 4 palabras.
    El nombre tiene que ser una síntesis de lo contenido en #{title_content}").ask(@chat.messages.first)
  end

  def update_chat_title_if_needed
    return unless @chat.title == "Nuevo Chat" && @chat.messages.first
    @chat.title = chat_title.content
    @chat.save
  end

  def build_conversation_history
    @ruby_llm_chat = RubyLLM.chat
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(role: message.role, content: message.content)
    end
  end

end
