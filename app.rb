require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'data_mapper'
require 'json'
require 'open-uri'
require 'nokogiri'

database_url = ENV['DATABASE_URL'] || 'mysql://localhost/sinatra_development'
DataMapper.setup :default, database_url

class ToWatch
  include DataMapper::Resource

  property :id,         Serial
  property :comment,    Text,     :default => ''
  property :link,       String,   :required => true
  property :title,      String
  property :watched,    Boolean,  :default => false
end

DataMapper.auto_upgrade!

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
  req  = request.body.read
  json = JSON.parse req
  tw   = ToWatch.new json

  tw.title = get_title_for_link tw.link if tw.title.nil?
  tw.save

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
  id   = params[:id].to_i
  tw   = ToWatch.get id
  text = request.body.read
  json = JSON.parse text

  return 404 if tw.nil?

  tw.update json
  return 400, tw.errors.to_hash.to_json unless tw.valid?
  tw.to_json
end

delete '/towatch/:id' do
  id = params[:id].to_i
  tw = ToWatch.get id
  return 404 if tw.nil?
  tw.destroy
end

# Return a convenient title for a link.
def get_title_for_link link
  begin
    doc  = Nokogiri::HTML open(link)
    node = doc.search('h1').first || doc.search('title').first
    node.xpath('.//text()').to_s.strip
  rescue
    # If something goes wrong (e.g. "link" is not a valid URL and "open" 
    # complained, or the resource is not HTML and Nokogiri shat the bed, or
    # the HTML had no 'h1' not 'title' tags, so "node" was nil, etc), use the 
    # link as a title :)
    link
  end
end
