require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sequel'
require 'json'
require 'open-uri'
require 'nokogiri'

# Connect to database.
db_url = ENV['DATABASE_URL']
if db_url
  # If a database URL is passed (e.g. on Heroku), connect to that database.
  Sequel.connect db_url
else
  # Use in-memory database.
  db = Sequel.sqlite

  # And create database schema for development.
  db.create_table :to_watches do
    primary_key :id
    text :comment
    text :link, :null => false
    text :title
    TrueClass :watched, :default => false
  end
end

# Prevent Model::update from raising exceptions when trying to update a
# restricted field (like an id). Useful when updating things from JSON.
Sequel::Model.strict_param_setting = false

class ToWatch < Sequel::Model
  plugin :json_serializer, :naked => true
end

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
  tw = ToWatch[id]

  return 404 if tw.nil?
  tw.to_json
end

put '/towatch/:id', :provides => :json do
  id   = params[:id].to_i
  tw   = ToWatch[id]
  text = request.body.read
  json = JSON.parse text

  return 404 if tw.nil?

  tw.update json
  return 400, tw.errors.to_hash.to_json unless tw.valid?
  tw.to_json
end

delete '/towatch/:id' do
  id = params[:id].to_i
  tw = ToWatch[id]
  return 404 if tw.nil?
  tw.destroy
  200
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
