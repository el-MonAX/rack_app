require './lib/racker'
require './lib/actions'
require 'rack/test'
require 'byebug'

describe Racker do
  include Rack::Test::Methods

  let(:response) { Racker.call(env) }
  let(:request) { Rack::Request.new(env) }
  let(:env) do
    {
      'PATH_INFO' => '/',
      'REQUEST_METHOD' => 'GET',
      'rack.session' => { 'session_id' => '_' }
    }
  end

  context 'GET to /' do
    it 'The HTTP response code is 200' do
      expect(response[0]).to eq 200
    end
  end

  context '#response' do
    let(:racker) { Racker.new(env) }
    let(:request) { racker.instance_variable_get(:@request) }
    let(:actions) { racker.instance_variable_get(:@actions) }
    after { racker.response }

    it 'when @request.path "/" run :welcome' do
      allow(request).to receive(:path).and_return("/")
      expect(actions).to receive(:welcome)
    end

    it 'when @request.path "start_game" run :start_game' do
      allow(request).to receive(:path).and_return("/start_game")
      expect(actions).to receive(:start_game)
    end

    it 'when @request.path "/game" run :game' do
      allow(request).to receive(:path).and_return("/game")
      expect(actions).to receive(:game)
    end

    it 'when @request.path "/attempt" run :attempt' do
      allow(request).to receive(:path).and_return("/attempt")
      expect(actions).to receive(:attempt)
    end

    it 'when @request.path "/hint" run :hint' do
      allow(request).to receive(:path).and_return("/hint")
      expect(actions).to receive(:hint)
    end

    it 'when @request.path "/you_win" run :you_win' do
      allow(request).to receive(:path).and_return("/you_win")
      expect(actions).to receive(:you_win)
    end

    it 'when @request.path "/you_lose" run :you_lose' do
      allow(request).to receive(:path).and_return("/you_lose")
      expect(actions).to receive(:you_lose)
    end
  end
end
