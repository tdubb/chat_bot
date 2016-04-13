class ChatRoomController < ApplicationController
  def show
    @messages = Message.all
  end


  def create
    @message = Message.create!(text: params[:q], sender: 1, receiver: 2)



    require 'musix_match'
    MusixMatch::API::Base.api_key = '0fa43bcc46f9340cc32b1edbe4196f77'
    if ARGV.length == 2
      query = { q: ARGV.first, q_artist: ARGV.last }
    else
      query = {q: ARGV.first}
    end
    # query = 'I think you suck, what do you think?'
    response = MusixMatch.search_track q: @message.text #, q_artist: "bon jovi"
    logger.debug "response"
    logger.debug response.status_code
    logger.debug response.inspect
    if response.status_code == 200
      response.each do |lyrics|
        # puts lyrics.track_name + lyrics.artist_name
        response = MusixMatch.get_lyrics(lyrics.track_id)
        # biggest = query.first[-1].split.group_by(&:size).max.last
        biggest = @message.text.split.sort_by(&:size).reverse
        logger.debug "biggest"
        logger.debug biggest
        biggest.each do |b|
          check_this = b.gsub(/[^a-z0-9\s]/i, '')
          if response.status_code == 200 && lyrics = response.lyrics
            sentence_count = lyrics.lyrics_body
            sentence_count.split(/\.|\?|!/).each do |sen|
              if sen.split.include?(check_this) && sen.length > 10
                Message.create!(text: sen[0..sen[0..100].rindex("\n")].gsub(/\(.*\)/, "").gsub(/\[.*\]/, "").gsub(/\n/, ". "), sender: 2, receiver: 1)
                redirect_to root_path and return
              end
            end
          end
        end
      end
      Message.create!(text: "Whatever man..", sender: 2, receiver: 1)
      redirect_to root_path and return
    end
  end

  def destroy
    Message.delete_all
    redirect_to root_path
  end
end
