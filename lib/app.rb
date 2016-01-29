# Api dependencies
require 'json'
require 'sinatra'
require 'sinatra/json'
require 'docker'

# Autoreload to speed iterations
require "sinatra/reloader" if ENV['RELOADER_ENABLED'] || false

# Add current path to the loading path
$: << File.expand_path('../', __FILE__)

class App < Sinatra::Application

  # Beewolf modules
  require 'beewolf/version'

  # Autoreload to speed iterations
  if ENV['RELOADER_ENABLED'] || false
    register Sinatra::Reloader
  end

  # We are open to the wolrd
  set :bind, '0.0.0.0'

  # Send info about us
  get '/version' do
    json({version: Beewolf::VERSION, api_version: Beewolf::API_VERSION})
  end

  get '/info' do
    Docker.url = 'tcp://172.17.0.1:2375'
    json(Docker.info)
  end
end
