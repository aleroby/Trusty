class AiStreamJob < ApplicationJob
  queue_as :default

  include ActionView::RecordIdentifier

  # Envia la pregunta del usuario al LLM en modo streaming y va
  # actualizando/broadcasteando el mensaje del asistente a medida que llegan chunks.
  def perform(chat_id, user_message_id, instructions)
    chat = Chat.find(chat_id)
    user_message = chat.messages.find(user_message_id)

    llm_chat = build_llm_chat(chat, instructions)

    # Creamos el mensaje del asistente vacío (validación ya relajada)
    assistant_message = chat.messages.create!(role: "assistant", content: "")

    # Lo mostramos enseguida en la UI
    broadcast_append_message(chat, assistant_message)

    buffer = +""

    llm_chat.ask(user_message.content) do |chunk|
      next if chunk.content.nil?

      buffer << chunk.content
      assistant_message.update!(content: buffer)

      # Reemplazamos el contenido en la UI en vivo
      broadcast_replace_message(chat, assistant_message)
    end
  end

  private

  def build_llm_chat(chat, instructions)
    llm = RubyLLM.chat.with_instructions(instructions)

    # Cargamos el historial sin el placeholder del asistente que se crea aquí
    chat.messages.order(:created_at).each do |message|
      llm.add_message(role: message.role, content: message.content)
    end

    llm
  end

  def broadcast_append_message(chat, message)
    Turbo::StreamsChannel.broadcast_append_to(
      chat,
      target: dom_id(chat, :messages),
      partial: "messages/message",
      locals: { message: message }
    )
  end

  def broadcast_replace_message(chat, message)
    Turbo::StreamsChannel.broadcast_replace_to(
      chat,
      target: dom_id(message),
      partial: "messages/message",
      locals: { message: message }
    )
  end
end
