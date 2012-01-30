require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'data_mapper'
require 'json'
require 'open-uri'
require 'nokogiri'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://localhost/sinatra_development')

class ToWatch
  include DataMapper::Resource

  property :id,         Serial
  property :comment,    Text,     :default => ''
  property :link,       String,   :required => true
  property :title,      String
  property :watched,    Boolean,  :default => false
end

DataMapper.auto_upgrade!

# Uncomment for some bootstrap data
#DataMapper.auto_migrate!
#Video.create :title => "RickRoll'D", :comment => 'For the lulz', :youtube_id => 'oHg5SJYRHA0'
#Video.create :title => "Nyan Cat [original]", :youtube_id => 'QH2-TGUlwu4'
#Video.create :title => "Another rick roll...", :comment => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', :youtube_id => 'oHg5SJYRHA0'

set :default_encoding => "utf-8"

get '/' do
  erb :app, :locals => {
      :to_watch_list => ToWatch.all
  }
end

get '/js/app.js' do
  coffee :app
end

get '/css/app.css' do
  sass :app
end

# REST methods for ToWatch resource.
post '/towatch', :provides => :json do
  json = JSON.parse(request.body.read)
  tw = ToWatch.new(json)
  tw.title = get_title_for_link tw.link if tw.title.nil?
  tw.save()

  return 400, tw.errors.to_hash.to_json unless tw.valid?
  tw.to_json
end

get '/towatch/:id', :provides => :json do
  id = params[:id].to_i
  tw = ToWatch.get id

  return 404 if tw.nil?
  tw.to_json
end

put '/towatch/:id', :provides => :json do
  id = params[:id].to_i
  tw = ToWatch.get(id)
  json = JSON.parse(request.body.read)

  return 404 if tw.nil?

  tw.update json
  return 400, tw.errors.to_hash.to_json unless tw.valid?
  tw.to_json
end

delete '/towatch/:id' do
  id = params[:id].to_i
  tw = ToWatch.get(id)
  return 404 if tw.nil?
  tw.destroy
end

# Return a convenient title for a link.
def get_title_for_link link
  begin
    doc = Nokogiri::HTML(open(link))
    node = doc.search('h1').first  || doc.search('title').first
    node.xpath('.//text()').to_s.strip
  rescue
    # If something goes wrong, use link as a title.
    link
  end
end
