class Human::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat
  before_action :authorize_chat!

  def index
    @messages = @chat.messages.includes(:user).order(created_at: :asc)
    render partial: "human/messages/list", locals: { messages: @messages }
  end

  def create
    @message = Human::Message.new(message_params)
    @message.human_chat = @chat
    @message.user = current_user

    if @message.save
      @chat.update(last_message_at: Time.current)
      redirect_to human_chat_path(@chat)
    else
      redirect_back fallback_location: human_chat_path(@chat), alert: @message.errors.full_messages.to_sentence
    end
  end

  private

  def set_chat
    @chat = Human::Chat.find(params[:chat_id])
  end

  def authorize_chat!
    return if [@chat.client_id, @chat.supplier_id].include?(current_user.id)

    head :forbidden
  end

  def message_params
    params.require(:human_message).permit(:content)
  end
end
