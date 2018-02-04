require_relative 'spec_helper'
require './lib/racker'

describe Actions do
  let(:racker) { Racker.new(TEST_ENV) }

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
end
