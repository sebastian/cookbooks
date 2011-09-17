#
# Cookbook Name:: writewithme
# Recipe:: default
#
# Copyright 2011, Kleio
#
# All rights reserved - Do Not Redistribute
#
include_recipe "unicorn"

name = "writewithme"
app_root = "/webapps/#{name}"
config_path = "#{app_root}/current/config/unicorn.conf.rb"
log_path = "#{app_root}/shared/log"

# Config
git = "https://sebastian@github.com/sebastian/Write-With-Me.git"

# To make sure we can use bundler to install app gems
gem_package "bundler"

puts "############################### Creating dir: #{app_root}"
# Create the supporting app structure
directory app_root do
  mode 0755
  action :create
  recursive true
end

puts "############################### Calling unicorn_instance for: #{name}"
unicorn_instance name do
	####
	# Unicorn
	log_path log_path
	conf_path config_path
	socket_path "/tmp/unicorn/#{name}.sock"
	backlog_limit 1
	timeout node[:unicorn][:timeout]
	pid_path "#{app_root}/shared/pids/unicorn.pid"
	
	# Workers
	worker_count 4
	worker_listeners true
	worker_bind_base_port 8001
	worker_bind_address "127.0.0.1"
	
	# Master
	master_bind_address "0.0.0.0"
	master_bind_port "8000"
	
	####
	# Bluepill
	app_root app_root
	rack_config_path "#{app_root}/config.ru"
	preload true
	unicorn_log_path log_path
	memory_limit 100
	user "nobody"
	group "nobody"
	cpu_limit cpu[:total]
end

	
# # Create an nginx configuration
# template "#{nginx_path}/conf/sites.d/#{name}.conf" do
#   source "app.conf.erb"
#   owner "root"
#   group "root"
#   mode 0644
#   variables(
# 		:description => app[:description],
#   	:ip => app[:ip],
# 		:port => app[:port],
# 		:server_name => app[:server_name],
# 		:root => base_path + name,
# 		:name => name
#   )
# 	notifies :reload, 'nginx'
# end