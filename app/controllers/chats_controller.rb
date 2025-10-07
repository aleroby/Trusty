class ChatsController < ApplicationController
def index
    @user = current_user
    @chat = Chat.new
    @chats = Chat.all
  end

  def show
    @chat = Chat.find(params[:id])
    @message = Message.new
  end

  def create
    @chat = Chat.new(title:"Nuevo Chat")
    @chat.user_id = current_user.id

    if @chat.save!
      redirect_to chat_path(@chat)
    else
      render :index, status: :unprocessable_entity
    end
  end
end
