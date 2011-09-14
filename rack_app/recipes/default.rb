#
# Cookbook Name:: rack_app
# Recipe:: default
#
# Copyright 2011, Kleio
#
# All rights reserved - Do Not Redistribute
#

# We rely on nginx/passenger being installed
include_recipe "passenger::install"

nginx_path = node[:passenger][:production][:path]
base_path = node[:rack_app][:base_path]

unless node[:rack_app][:apps].empty? then
	# Create the supporting app structure
	directory base_path do
	  mode 0755
	  action :create
	  recursive true
	end

	node[:rack_app][:apps].each do |app|

		name = app[:app_name_short]
		break unless name # We require a name
		
		# Create a folder for the source code of the app
		directory base_path + name do
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
			notifies :reload, 'service[passenger]'
		end
		
	end
end
