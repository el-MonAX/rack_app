require_relative 'spec_helper'
require './lib/racker'
require './lib/actions'
require 'rack/test'
require 'byebug'

describe Actions do
  let(:racker) { Racker.new(TEST_ENV) }
  let(:actions) { racker.instance_variable_get(:@actions) }

  context '#racker' do
    it 'run :new, :response, :finish' do
      expect(Racker).to receive_message_chain(:new, :response, :finish)
      Racker.call(TEST_ENV)
    end
  end

  context '#new' do
    it '@request exist and be kind of Rack::Request' do
      request = racker.instance_variable_get(:@request)
      expect(request).to be_kind_of(Rack::Request)
    end
  end

  context '#start_game' do
    before do
      allow(actions).to receive(:game_session).and_return(true)
      allow(actions).to receive(:cookie_player_name).and_return('ebony')
      allow(actions).to receive(:cookie_attempts_quantity).and_return('5')
    end

    it '@request session clear when game_session is true' do
      expect(actions.instance_variable_get(:@request).session).to receive(:clear)
      actions.start_game
    end

    it 'create @request.session[:game] when game_session is true' do
      actions.start_game
      game_session = racker.instance_variable_get(:@request).session[:game]
      expect(game_session.attempts_quantity).to eq 5
    end

    it 'create @request.session[:game] when game_session is false' do
      allow(actions).to receive(:game_session).and_return(false)
      allow(actions).to receive(:params_player_name).and_return('den')
      allow(actions).to receive(:params_attempts_quantity).and_return('10')
      actions.start_game
      game_session = racker.instance_variable_get(:@request).session[:game]
      expect(game_session.attempts_quantity).to eq 10
    end

    it 'exist empty hash [:result] in @request.session' do
      actions.start_game
      hash = racker.instance_variable_get(:@request).session[:result]
      expect(hash).to be_kind_of(Hash)
    end

    it 'redirect to "/game"' do
      action = actions.start_game
      expect(action.location).to eq '/game'
    end
  end

  context '#game' do
    it 'render game.html.erb' do
      allow(actions).to receive(:render).and_return("game.html.erb")
      expect(Rack::Response).to receive(:new).with(actions.render("game.html.erb"))
      actions.game
    end
  end

  context '#attempt' do
    before do
      allow(racker).to receive(:cookie_player_name).and_return('ebony')
      allow(racker).to receive(:cookie_attempts_quantity).and_return('5')
      actions.start_game
    end

    it 'answer to be false' do
      allow(actions).to receive(:params_player_code).and_return('')
      actions.attempt
      answer = racker.instance_variable_get(:@request).session[:result]
      expect(answer).to eq( { ""=>false } )
    end

    it 'not to be false' do
      allow(actions).to receive(:params_player_code).and_return('1111')
      actions.attempt
      answer = racker.instance_variable_get(:@request).session[:result]["1111"]
      expect(answer).not_to be_falsey
    end

    it 'if game victory, run :save_to_statistics' do
      allow(actions.game_session).to receive(:victory?).and_return(true)
      expect(actions).to receive(:save_to_statistics)
      actions.attempt
    end

    it 'redirect to "/you_win"' do
      allow(actions.game_session).to receive(:victory?).and_return(true)
      allow(actions).to receive(:save_to_statistics).and_return(true)
      action = actions.attempt
      expect(action.location).to eq "/you_win"
    end

    it 'redirect to "/you_win"' do
      allow(actions.game_session).to receive(:lose?).and_return(true)
      action = actions.attempt
      expect(action.location).to eq "/you_lose"
    end

    it 'redirect to "/you_win"' do
      allow(actions.game_session).to receive(:victory?).and_return(false)
      allow(actions.game_session).to receive(:lose?).and_return(false)
      action = actions.attempt
      expect(action.location).to eq "/game"
    end
  end

  context '#welcome' do
    it 'request clear session' do
      request_session = racker.instance_variable_get(:@request).session
      expect(request_session).to receive(:clear)
      actions.welcome
    end

    it 'render "welcome.html.erb"' do
      expect(Rack::Response).to receive(:new).with(actions.render("welcome.html.erb"))
      actions.welcome
    end
  end

  context '#you_win' do
    before { allow(actions).to receive(:render).and_return("you_win.html.erb") }

    it 'YAML run :load_documents' do
      allow(File).to receive(:open).and_return("statistics.txt")
      expect(YAML).to receive(:load_documents).with("statistics.txt")
      actions.you_win
    end

    it 'render "you_win.html.erb"' do
      expect(Rack::Response).to receive(:new).with(actions.render("you_win.html.erb"))
      actions.you_win
    end
  end

  context '#you_lose' do
    it 'render you_lose.html.erb' do
      allow(actions).to receive(:render).and_return("you_lose.html.erb")
      expect(Rack::Response).to receive(:new).with(actions.render("you_lose.html.erb"))
      actions.you_lose
    end
  end

  context '#save_to_statistics' do
    before { actions.start_game }

    it 'exist file statistics.txt' do
      allow(actions).to receive(:cookie_player_name).and_return('ebony')
      allow(actions.game_session).to receive(:count).and_return(10)
      allow(actions.game_session).to receive(:player_arr).and_return([1,1,1,1])
      expect(File.exist?("./database/statistics.txt")).to eq true
      actions.save_to_statistics
    end
  end
  #
  context '#params_player_code' do
    it 'return "1111" from @request.params["player_code"]' do
      request = racker.instance_variable_get(:@request)
      allow(request).to receive(:params).and_return({"player_code"=>"1111"})
      expect(actions.params_player_code).to eq "1111"
    end
  end

  context '#params_player_name' do
    it 'return "ebony" from @request.params["player_name"]' do
      request = racker.instance_variable_get(:@request)
      allow(request).to receive(:params).and_return({"player_name"=>"ebony"})
      expect(actions.params_player_name).to eq "ebony"
    end
  end
  #
  context '#params_attempts_quantity' do
    it 'return "10" from @request.params["attempts_quantity"]' do
      request = racker.instance_variable_get(:@request)
      allow(request).to receive(:params).and_return({"attempts_quantity"=>"10"})
      expect(actions.params_attempts_quantity).to eq "10"
    end
  end
  #
  context '#cookie_player_name' do
    it 'return "ebony" from @request.cookie["player_name"]' do
      request = racker.instance_variable_get(:@request)
      allow(request).to receive(:cookies).and_return({"player_name"=>"ebony"})
      expect(actions.cookie_player_name).to eq "ebony"
    end
  end
  #
  context '#cookie_attempts_quantity' do
    it 'return "10" from @request.cookie["attempts_quantity"]' do
      request = racker.instance_variable_get(:@request)
      allow(request).to receive(:cookies).and_return({"attempts_quantity"=>"10"})
      expect(actions.cookie_attempts_quantity).to eq "10"
    end
  end
  #
  context '#cookie_hint' do
    before { @request = racker.instance_variable_get(:@request) }
    let(:request) { racker.instance_variable_get(:@request) }

    it '@request.cookies["hint"] return "***2"' do
      allow(@request).to receive(:cookies).and_return({"hint"=>"***2"})
      expect(actions.cookie_hint).to eq "***2"
    end
  end
end
