class MusixMatchApi
  require 'musix_match'

  def self.new(argv, message)
    set_api_key
    response = get_tracks(message)
    return if cycle_through_songs(response, message) && response.status_code == 200
    default_message
  end

  private

  def self.set_api_key
    MusixMatch::API::Base.api_key = '0fa43bcc46f9340cc32b1edbe4196f77'
  end

  def self.get_tracks(message)
    response = MusixMatch.search_track q: message.text #, q_artist: "bon jovi"
  end

  def self.default_message
    Message.create!(text: "Whatever man..", sender: 2, receiver: 1)
  end

  def self.cycle_through_songs(response, message)
    response.each do |lyrics| #cycle through all songs to see if you find one containing key word(biggest)
      response = MusixMatch.get_lyrics(lyrics.track_id) #pull track based off of track_id
      biggest = message.text.split.sort_by(&:size).reverse #find biggest word in query
      biggest.each do |b|
        check_this = b.gsub(/[^a-z0-9\s]/i, '') #remove all non numerical, digital or whitespace characters
        if response.status_code == 200 && lyrics = response.lyrics
          sentence_count = lyrics.lyrics_body
          sentence_count.split(/\.|\?|!/).each do |sen|
            if sen.split.include?(check_this) && sen.length > 10 #verifying key work is in the sentence and that the sentence is over 10 characters long
              #sen get from 0 up to the first index of 'n' within index 100 /
              #gsub to remove parantheses, brackets with empty space and new line tags with single space
              Message.create!(text: sen[0..sen[0..100].rindex("\n")].gsub(/\(.*\)|\[.*\]/, "").gsub(/\n/, ". "), sender: 2, receiver: 1)
              return true
            end
          end
        end
      end
    end
    false
  end
end
