require 'sinatra'
require 'sinatra/reloader'
require './lib/collectd'
require 'rrd'
require 'json'

configure do
  set :public_folder, File.dirname(__FILE__) + '/static'
end

get '/' do
  hosts = Collectd.get_hosts
  erb :index, :locals => { :hosts => hosts, :host => nil, :plugins => nil, :graphs => nil }
end

get '/host/:name' do
  host = params[:name]
  hosts = Collectd.get_hosts
  plugins = Collectd.get_plugins(host)
  erb :index, :locals => { :hosts => hosts, :host => host, :plugins => plugins, :plugin => nil, :graphs => nil }
end

get '/host/:host/plugin/:plugin' do
  host = params[:host]
  plugin = params[:plugin]
  graphs = Collectd.get_graphs(host, plugin)
  hosts = Collectd.get_hosts
  plugins = Collectd.get_plugins(host)
  erb :index, :locals => { :hosts => hosts, :host => host, :plugins => plugins, :plugin => plugin, :graphs => graphs, :graph => nil}
end

get '/host/:host/plugin/:plugin/graph/:graph' do
  host = params[:host]
  plugin = params[:plugin]
  graph = params[:graph]
  graphs = Collectd.get_graphs(host, plugin)
  hosts = Collectd.get_hosts
  plugins = Collectd.get_plugins(host)
  rrd = RRD::Base.new(Collectd.get_rrd_path(host, plugin, graph))
  x = []
  y = []
  data = nil
  data = rrd.fetch(:average)
  if data
    i = 0
    data.each do |line|
      xval, yval = line.map { |n| n.to_f }
      next if xval.nan? || yval.nan?
      x << i
      i += 1
      y << yval
    end
  end
  graph_data = { "x" => x, "y" => y }
  erb :index, :locals => { :hosts => hosts, :host => host, :plugins => plugins, :plugin => plugin, :graphs => graphs, :graph => graph, :graph_data => graph_data }
end
