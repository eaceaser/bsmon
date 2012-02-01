require 'sinatra'
#require 'sinatra/reloader'
require './lib/collectd'
require 'rrd'
require 'json'

configure do
  set :public_folder, File.dirname(__FILE__) + '/static'
end

get '/host/:host/plugin/:plugin/graph/:graph/data' do
  content_type :json
  @current_host = params[:host]
  @current_plugin = params[:plugin]
  @current_graph = params[:graph]

  rrd = RRD::Base.new(Collectd.get_rrd_path(@current_host, @current_plugin, @current_graph))
  x = []
  y = []
  data = nil
  data = rrd.fetch(:average)
  if data
    i = 0
    data.each do |line|
      xval, yval = line.map { |n| n.to_f }
      next if xval.nan? || yval.nan? || xval == 0
      x << xval
      y << yval
    end
  end
  graph_data = { "x" => x, "y" => y }
  graph_data.to_json
end

get '/' do
  @hosts = Collectd.get_hosts
  erb :index
end

get '/host/:name' do
  @current_host = params[:name]

  @hosts = Collectd.get_hosts
  @plugins = Collectd.get_plugins(@current_host)
  erb :index
end

get '/host/:host/plugin/:plugin' do
  @current_host = params[:host]
  @current_plugin = params[:plugin]
  @graphs = Collectd.get_graphs(@current_host, @current_plugin)
  erb :index
end

get '/host/:host/plugin/:plugin/graph/:graph' do
  @current_host = params[:host]
  @current_plugin = params[:plugin]
  @current_graph = params[:graph]
  @graphs = Collectd.get_graphs(@current_host, @current_plugin)
  erb :index
end
