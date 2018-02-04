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
end
