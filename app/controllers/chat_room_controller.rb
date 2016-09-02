class ChatRoomController < ApplicationController

  def show
    @messages = Message.all
  end


  def create
    message = Message.create!(text: params[:q], sender: 1, receiver: 2)

    ::MusixMatchApi.new(ARGV, message)
    redirect_to root_path and return
  end

  def destroy
    Message.all.map(&:destroy)
    redirect_to root_path
  end
end
