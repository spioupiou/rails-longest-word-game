require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    consonants = %w[B C D F G H J K L M N P Q R S T V W X Y Z]
    vowels = %w[A E I O U]
    @letters = []
    @score = session[:score]

    6.times do
      @letters << consonants[rand(21)]
    end

    4.times do
      @letters << vowels[rand(5)]
    end

    @letters.shuffle!
  end

  def score
    @user_input = params["word"].upcase
    @letters = JSON.parse(params["letters"].tr("'", '"'))

    api_hash = generate_hash(@user_input)

    return @message = "Sorry, #{@user_input} can't be build out of #{@letters}" unless analyze_word(@user_input, @letters)

    if api_hash['found']
      @message =  "Congrats! #{@user_input} is a valid English word!"
      session[:score] = generate_score(@user_input)
    else
      @message = "Sorry, #{@user_input} is not an English word"
    end
  end

  def reset
    reset_session
    redirect_to('/new')
  end

  private

  def analyze_word(word, array)
    word = word.split('')
    array_cp = array.clone

    word.each do |letter|
      return false unless array_cp.include?(letter)

      array_cp.delete_at(array_cp.index(letter))
    end

    true
  end

  def generate_hash(keyword)
    url = "https://wagon-dictionary.herokuapp.com/#{keyword}"
    html = URI.open(url).read
    JSON.parse(html)
  end

  def generate_score(word_length)
    if session[:score].nil?
      session[:score] = @user_input.length
    elsif @user_input.length > session[:score]
      session[:score] = @user_input.length
    else
      return session[:score]
    end
  end
end
