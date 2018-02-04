require './lib/racker'
require './lib/actions'
require 'rack/test'

describe Racker do
  include Rack::Test::Methods

  let(:response) { Racker.call(env) }
  context 'GET to /' do
    let(:env) { { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/', 'rack.session' => { 'session_id' => '_' } } }

    it 'The HTTP response code is 200' do
      expect(response[0]).to eq 200
    end
  end

  context '#response' do
    before { @request = racker.instance_variable_get(:@request) }
    after { racker.response }

    it 'when @request.path "/" run :welcome' do
      allow(@request).to receive(:path).and_return("/")
      expect(racker).to receive(:welcome)
    end

    it 'when @request.path "start_game" run :start_game' do
      allow(@request).to receive(:path).and_return("/start_game")
      expect(racker).to receive(:start_game)
    end

    it 'when @request.path "/game" run :game' do
      allow(@request).to receive(:path).and_return("/game")
      expect(racker).to receive(:game)
    end

    it 'when @request.path "/attempt" run :attempt' do
      allow(@request).to receive(:path).and_return("/attempt")
      expect(racker).to receive(:attempt)
    end

    it 'when @request.path "/hint" run :hint' do
      allow(@request).to receive(:path).and_return("/hint")
      expect(racker).to receive(:hint)
    end

    it 'when @request.path "/you_win" run :you_win' do
      allow(@request).to receive(:path).and_return("/you_win")
      expect(racker).to receive(:you_win)
    end

    it 'when @request.path "/you_lose" run :you_lose' do
      allow(@request).to receive(:path).and_return("/you_lose")
      expect(racker).to receive(:you_lose)
    end
  end
end
