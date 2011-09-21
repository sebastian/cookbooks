#
# Cookbook Name:: writewithme
# Recipe:: default
#
# Copyright 2011, Kleio
#
# All rights reserved - Do Not Redistribute
#
include_recipe "nginx"

name = "writewithme"
user = "writewithme"
group = "writewithme"
deploy_user = "#{user}-deploy"
deploy_group = "#{group}-deploy"

app_root = "/webapps/#{name}"
current_dir = "#{app_root}/current"
shared_dir = "#{app_root}/shared"
conf_dir = "#{shared_dir}/config"
config_path = "#{conf_dir}/unicorn.conf.rb"
log_dir = "#{shared_dir}/log"
pid_dir = "#{shared_dir}/pids"
writewithme_pid_path = "#{pid_dir}/unicorn.pid"
www_sock_path = "#{current_dir}/tmp"
story_dir = "#{shared_dir}/story"
sock_path_name = "#{www_sock_path}/#{name}.sock"
public_path = "#{current_dir}/public"

# Config
git = "https://sebastian@github.com/sebastian/Write-With-Me.git"

# To make sure we can use bundler to install app gems
gem_package "bundler"
gem_package "i18n"
%w{sqlite3 sinatra erubis active_support}.each do |gem_name|
	gem_package gem_name
end

# Create the supporting app structure
[app_root, shared_dir, "#{shared_dir}/db", story_dir, conf_dir, log_dir, pid_dir].each do |directory|
	directory directory do
	  mode 0775
	  group deploy_user
	  owner deploy_group
	  action :create
	  recursive true
	end
end

unicorn_instance name do
	####
	# Unicorn
	log_path log_dir
	conf_path config_path
	socket_path sock_path_name
	backlog_limit 2048
	pid_path writewithme_pid_path
	
	# Workers
	worker_count 8
	worker_listeners false
	worker_bind_base_port 8001
	worker_bind_address "127.0.0.1"
	
	# Master
	master_bind_address "0.0.0.0"
	master_bind_port "8000"
	
	####
	# Bluepill
	app_root current_dir
	unicorn_config_path config_path
	rack_config_path "#{current_dir}/config.ru"
	preload true
	unicorn_log_path log_dir
	memory_limit 100
	cpu_limit 40 # %
	env "production"
	
	####
	# General
	user user
	group deploy_group
end
	
# Create an nginx configuration
template "/etc/nginx/sites-available/#{name}.conf" do
  source "web_app.conf.erb"
	cookbook "unicorn"
  owner user
  group group
  mode 0644
  variables(
		"port" => 80,
		"app_name" => "writewithme",
		"socket_path" => sock_path_name,
		"upstream_server_ip" => "0.0.0.0",
		"upstream_server_port" => 8000,
		"server_name" => node["web_environment"] == "staging" ? "writewithme.local" : "writewithme.kle.io",
		"static_path" => public_path,
		"keep_alive_timeout" => 60
  )
	notifies :reload, resources(:service => "nginx")
end

execute "nxensite #{name}" do
  command "/usr/sbin/nxensite #{name}.conf"
  notifies :restart, resources(:service => "nginx")
  not_if do ::File.symlink?("#{node[:nginx][:dir]}/sites-enabled/#{name}") end
end