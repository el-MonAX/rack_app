require 'erb'
require 'yaml'
require 'rack'
require 'codebreaker'

class Racker
  def self.call(env)
    new(env).response.finish
  end
end
