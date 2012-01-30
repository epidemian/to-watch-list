require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'data_mapper'
require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://localhost/sinatra_development')

class Video
  include DataMapper::Resource

  property :id,         Serial
  property :title,      String,   :default => ''
  property :comment,    Text,     :default => ''
  property :youtube_id, String,   :required => true
  property :watched,    Boolean,  :default => false
end

DataMapper.auto_upgrade!

# Uncomment for some bootstrap data
#DataMapper.auto_migrate!
#Video.create :title => "RickRoll'D", :comment => 'For the lulz', :youtube_id => 'oHg5SJYRHA0'
#Video.create :title => "Nyan Cat [original]", :youtube_id => 'QH2-TGUlwu4'
#Video.create :title => "Another rick roll...", :comment => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', :youtube_id => 'oHg5SJYRHA0'

get '/' do
  erb :app, :locals => {
      :videos => Video.all
  }
end

get '/js/app.js' do
  coffee :app
end

get '/css/app.css' do
  sass :app
end

# REST methods for Video resource.
post '/videos', :provides => :json do
  json = JSON.parse(request.body.read)
  video = Video.create(json)

  return 400, video.errors.to_hash.to_json unless video.valid?
  video.to_json
end

get '/videos/:id', :provides => :json do
  id = params[:id].to_i
  video = Video.get id

  return 404 if video.nil?
  video.to_json
end

put '/videos/:id', :provides => :json do
  id = params[:id].to_i
  video = Video.get(id)
  json = JSON.parse(request.body.read)

  return 404 if video.nil?

  video.update json
  return 400, video.errors.to_hash.to_json unless video.valid?
  video.to_json
end

delete '/videos/:id' do
  id = params[:id].to_i
  video = Video.get(id)
  return 404 if video.nil?
  video.destroy
end