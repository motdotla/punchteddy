require 'rubygems'
require 'sinatra'
require 'haml'

get '/' do
  @muscle_power = 100
  haml :index
end

get '/punchteddy' do
  @muscle_power = 5
  haml :index
end