#
# Cookbook Name:: writewithme
# Recipe:: default
#
# Copyright 2011, Kleio
#
# All rights reserved - Do Not Redistribute
#

name = "writewithme"
config = {
	:rack_only => true,
	:enable => true
}
unicorn_instance :enable => true

# Create the supporting app structure
directory "/u/apps/#{name}" do
  mode 0755
  action :create
  recursive true
end
		
# Create an nginx configuration
template "#{nginx_path}/conf/sites.d/#{name}.conf" do
  source "app.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
		:description => app[:description],
  	:ip => app[:ip],
		:port => app[:port],
		:server_name => app[:server_name],
		:root => base_path + name,
		:name => name
  )
	notifies :reload, 'nginx'
end
		
%w{sinatra sqlite3 erubis}.each do |gem_name|
	gem_package gem_name
end