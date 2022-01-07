require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    alphabet = %w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]
    @letters = []
    10.times do
      @letters << alphabet[rand(26)]
    end
  end

  def score
    @user_input = params["word"].upcase
    @letters = params["letters"]

    token = params[:authenticity_token]
    api_hash = generate_hash(@user_input)

    if token
      return @message = "Sorry but #{@user_input} can't be build out of #{@letters}" unless analyze_word(@user_input, @letters)

      @message = api_hash['found'] ? "Congrats! #{@user_input} is a valid English word!" : 'Sorry, not an English word'
    else
      @message = 'ACCESS DENIED'
    end
  end
end

private

def analyze_word(word, array)
  word = word.split('')
  word.each do |letter|
    return false unless array.include?(letter)
  end
  true
end

def generate_hash(keyword)
  url = "https://wagon-dictionary.herokuapp.com/#{keyword}"
  html = URI.open(url).read
  JSON.parse(html)
end
