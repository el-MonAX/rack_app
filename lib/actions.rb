# frozen_string_literal: true

require 'erb'
require 'yaml'
require 'codebreaker'

class Actions
  attr_accessor :request

  def initialize(request)
    @request = request
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def start_game
    Rack::Response.new do |response|
      response.delete_cookie("hint")
      if game_session
        request.session.clear
        request.session[:game] = Codebreaker::Game.new(cookie_player_name, cookie_attempts_quantity.to_i)
      else
        response.set_cookie("player_name", params_player_name)
        response.set_cookie("attempts_quantity", params_attempts_quantity)
        request.session[:game] = Codebreaker::Game.new(params_player_name, params_attempts_quantity.to_i)
      end
      request.session[:result] = {}
      response.redirect("/game")
    end
  end

  def game
    Rack::Response.new(render("game.html.erb"))
  end

  def attempt
    answer = game_session.guess(params_player_code)
    request.session[:result][params_player_code] = answer
    Rack::Response.new do |response|
      if game_session.victory?
        save_to_statistics
        response.redirect("/you_win")
      elsif game_session.lose?
        response.redirect("/you_lose")
      else
        response.redirect("/game")
      end
    end
  end

  def hint
    Rack::Response.new do |response|
      if hint == game_session.check_hint
        response.set_cookie("hint", hint)
        response.redirect("/game")
      else
        response.redirect("/game")
      end
    end
  end

  def welcome
    request.session.clear
    Rack::Response.new(render('welcome.html.erb'))
  end

  def you_win
    @statistics = YAML.load_documents(File.open("./database/statistics.txt"))
    Rack::Response.new(render("you_win.html.erb"))
  end

  def you_lose
    Rack::Response.new(render("you_lose.html.erb"))
  end

  def save_to_statistics
    winner = {
      name: cookie_player_name,
      attempts_count: game_session.count,
      secret_code: game_session.player_arr.join
    }
    File.open("./database/statistics.txt", 'a') { |file|  file.write(YAML.dump(winner)) }
  end

  def params_player_code
    request.params["player_code"]
  end

  def params_player_name
    request.params["player_name"]
  end

  def params_attempts_quantity
    request.params["attempts_quantity"]
  end

  def cookie_player_name
    request.cookies["player_name"]
  end

  def cookie_attempts_quantity
    request.cookies["attempts_quantity"]
  end

  def cookie_hint
    request.cookies["hint"]
  end

  def game_session
    request.session[:game]
  end
end
