require 'pp'

module Collectd
  @@path = "/var/lib/collectd/rrd"

  public
  def Collectd.get_hosts
    Dir.glob("#{@@path}/*").map do |filename|
      filename.split("/").last
    end
  end

  def Collectd.get_plugins(host)
    Dir.glob("#{@@path}/#{host}/*").map do |filename|
      print filename
      filename.split("/").last
    end
  end

  def Collectd.get_graphs(host, plugin)
    Dir.glob("#{@@path}/#{host}/#{plugin}*").map do |dir|
      rrds = Dir.glob("#{dir}/*.rrd").map do |rrd|
        filename = rrd.split("/").last[0..-5]
        filename
      end
    end.flatten
  end

  def Collectd.get_rrd_path(host, plugin, graph)
    "#{@@path}/#{host}/#{plugin}/#{graph}.rrd"
  end
end
