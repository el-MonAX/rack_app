# frozen_string_literal: true

require './lib/actions'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @actions = Actions.new(@request)
  end

  def response
    case @request.path
    when '/'           then @actions.welcome
    when '/start_game' then @actions.start_game
    when "/game"       then @actions.game
    when '/attempt'    then @actions.attempt
    when '/hint'       then @actions.hint
    when '/you_win'    then @actions.you_win
    when '/you_lose'   then @actions.you_lose
    else Rack::Response.new("Not Found", 404)
    end
  end
end
