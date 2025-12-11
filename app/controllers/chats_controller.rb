class ChatsController < ApplicationController
  before_action :set_chat, only: %i[show details destroy]

  def index
    @user = current_user
    @chat = Chat.new
    @chats = Chat.order(updated_at: :desc)
  end

  def show
    @message = Message.new
  end

def details
  @service = Service.find_by(id: params[:service_id])
  @order_for_service = if @service.present? && current_user
                         Order.where(service: @service, user: current_user).order(created_at: :desc).first
                       end

  if @service.present?
    scope = Review.for_this_service_supplier(@service.id)
    @service_avg = (scope.average(:rating) || 0).round(2)
    @service_count = scope.count
  end
end


  def create
    @chat = Chat.new(title: "Nuevo Chat")
    @chat.user_id = current_user.id

    if @chat.save!
      redirect_to chat_path(@chat)
    else
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @chat.destroy
    redirect_to chats_path, notice: "Chat eliminado."
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end
end
