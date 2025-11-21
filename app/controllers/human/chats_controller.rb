class Human::ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: %i[show archive reopen details]
  before_action :authorize_chat!, only: %i[show archive reopen details]

  def index
    base = Human::Chat
             .where(client: current_user)
             .or(Human::Chat.where(supplier: current_user))
             .includes(:service, :order, messages: :user)
             .order(last_message_at: :desc, updated_at: :desc)

    chats = base.to_a
    @unread_count = chats.count { |chat| chat.unread_for?(current_user) }

    @filter = params[:filter].presence || "all"
    @chats = if @filter == "unread"
               chats.select { |chat| chat.unread_for?(current_user) }
             else
               chats
             end
  end

  def show
    @messages = @chat.messages.includes(:user).order(created_at: :asc)
    @chat.mark_as_read_for(current_user)
  end

  def create
    service = Service.find(params[:service_id])
    supplier = service.user

    unless supplier
      redirect_back fallback_location: service_path(service), alert: "Proveedor no disponible" and return
    end

    if supplier == current_user
      redirect_back fallback_location: service_path(service), alert: "No puedes enviarte mensajes a ti mismo" and return
    end

    @chat = Human::Chat.find_or_initialize_by(
      service:,
      client: current_user,
      supplier:
    )

    if @chat.persisted?
      success, error_message = attach_initial_message(@chat)
      if success
        redirect_to human_chat_path(@chat)
      else
        redirect_back fallback_location: service_path(service), alert: error_message
      end
      return
    end

    @chat.status = "open"
    @chat.last_message_at = Time.current

    if @chat.save
      success, error_message = attach_initial_message(@chat)
      if success
        redirect_to human_chats_path, notice: "Chat creado"
      else
        redirect_back fallback_location: service_path(service), alert: error_message
      end
    else
      redirect_back fallback_location: service_path(service), alert: @chat.errors.full_messages.to_sentence
    end
  end

  def archive
    if @chat.update(status: "archived")
      redirect_to human_chats_path, notice: "Chat archivado"
    else
      redirect_back fallback_location: human_chats_path, alert: @chat.errors.full_messages.to_sentence
    end
  end

  def reopen
    if @chat.update(status: "open")
      redirect_to human_chats_path, notice: "Chat reabierto"
    else
      redirect_back fallback_location: human_chat_path(@chat), alert: @chat.errors.full_messages.to_sentence
    end
  end

  def details
  end

  private

  def set_chat
    @chat = Human::Chat.find(params[:id])
  end

  def authorize_chat!
    return if [@chat.client_id, @chat.supplier_id].include?(current_user.id)

    head :forbidden
  end

  def initial_message_content
    params.dig(:human_message, :content).to_s.strip
  end

  def attach_initial_message(chat)
    content = initial_message_content
    return [true, nil] if content.blank?

    message = chat.messages.build(content:, user: current_user)

    if message.save
      chat.update(last_message_at: Time.current)
      [true, nil]
    else
      [false, message.errors.full_messages.to_sentence]
    end
  end
end
