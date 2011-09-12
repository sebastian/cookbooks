#
# Cookbook Name:: rack_app
# Recipe:: default
#
# Copyright 2011, Kleio
#
# All rights reserved - Do Not Redistribute
#

nginx_path = node[:passenger][:production][:path]
short_name = node[:rack_app][:app_name_short]
app_root = node[:rack_app][:app_path]

# Create the app structure
directory app_root do
  mode 0755
  action :create
  recursive true
end

template "#{nginx_path}/conf/sites.d/#{short_name}.conf" do
  source "app.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
  	:ip => node[:rack_app][:ip],
		:port => node[:rack_app][:port],
		:server_name => node[:rack_app][:server_name],
		:root => app_root
  )
	notifies :reload, 'service[passenger]'
end