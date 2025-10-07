class MessagesController < ApplicationController

  if Rails.env.development?
    host = "http://localhost:3000"
  else
    host = "https://trustyservices.me"
  end

  def create
    @chat = Chat.find(params[:chat_id])
    embedding = RubyLLM.embed(params[:message][:content])
    # Repetir esta linea para los distintos modelos
    services = Service.nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(5)
    reviews = Review.nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(5)
    users = User.nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(5)
    vectors = services + reviews + users
    instructions = system_prompt

    instructions += vectors.map { |vector| models_prompt(vector) }.join("\n\n")

    @message = Message.new(message_params)
    @message.role = "user"
    @message.chat_id = @chat.id

    if @message.save
      if @chat.title == "Nuevo Chat"
        @chat.title = chat_title.content
        @chat.save
      end
      build_conversation_history
      response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      # @chat.with_instructions(instructions).ask(@message.content)cha
      Message.create(role: "assistant", chat_id: @chat.id, content: response.content)
      redirect_to chat_path(@chat)
    else
      render "/chats/show", status: :unprocessable_entity
    end
  end

  private

  def build_conversation_history
    @ruby_llm_chat = RubyLLM.chat
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(role: message.role, content: message.content)
    end
  end

  def chat_title
    message = @chat.messages.first.content
    RubyLLM.chat.with_instructions("Genera un nombre descriptivo para un chat que no sea mas de 6 palabras.
    El nombre tiene que ser una síntesis de lo contenido en #{message}").ask(@chat.messages.first)
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def system_prompt
    "Actúa como un asistente personalizado de una plataforma de servicios al estilo de Airbnb. \
      Tu tarea es responder a las consultas que te hagan los potenciales clientes de la aplicación,
      buscando los servicios que te pidan, recomendando las opciones que tengan mejores
      calificaciones (rating), en promedio y cantidad, y devolviendo como resultado sólo aquellos
      proveedores (suppliers) que ofrezcan sus servicios en la dirección del cliente o de la consulta. \
      Si no hay proveedores/servicios disponibles para la consulta, puedes responder
      \"No hay servicios disponibles para esta consulta\". \
      Tu respuesta debe ser en formato markdown. Cuando respondas, no solo te pedimos las url
      de los servicios que cumplan con los solicitado sino tambien una url con query string
      (http://127.0.0.1:3000/services?mode=filtros&category=Wellness&sub_category=Clases+de+Meditacion&price_max=47125&location=Av.+Santa+Fe+3300+%2C+Buenos+Aires&commit=Aplica+filtros)
      con la lista de los servicios que cumplen con lo solicitado."
  end

  def models_prompt(vector)
    case vector
    when Service
      "SERVICE id: #{vector.id}, category: #{vector.category}, sub_category: #{vector.sub_category},
      description: #{vector.description}, price: #{vector.price}, url: #{service_url(vector)}"
    when Review
      "REVIEW id: #{vector.id}, rating: #{vector.rating}, comment: #{vector.content}"
    when User
      "USER id: #{vector.id}, address: #{vector.address}, latitude: #{vector.latitude}, longitude: #{vector.longitude},
      radius: #{vector.radius}"
    else
      ""
    end
  end

end
