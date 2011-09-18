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
app_root = "/webapps/#{name}"
conf_dir = "#{app_root}/current/config"
config_path = "#{conf_dir}/unicorn.conf.rb"
log_dir = "#{app_root}/shared/log"
pid_dir = "#{app_root}/shared/pids"
writewithme_pid_path = "#{pid_dir}/unicorn.pid"
www_sock_path = "/tmp/unicorn/#{name}.sock"
public_path = "#{app_root}/public"

# Config
git = "https://sebastian@github.com/sebastian/Write-With-Me.git"

# To make sure we can use bundler to install app gems
gem_package "bundler"
gem_package "i18n"

# Create the supporting app structure
[app_root, conf_dir, log_dir, pid_dir].each do |directory|
	directory directory do
	  mode 0755
	  action :create
	  recursive true
	end	
end

unicorn_instance name do
	####
	# Unicorn
	log_path log_dir
	conf_path config_path
	socket_path www_sock_path
	backlog_limit 1
	pid_path writewithme_pid_path
	
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
	unicorn_log_path log_dir
	memory_limit 100
	user "nobody"
	group "nobody"
	cpu_limit 2
	env "production"
end
	
# Create an nginx configuration
template "/etc/nginx/sites-available/#{name}.conf" do
  source "web_app.conf.erb"
	cookbook "unicorn"
  owner "root"
  group "root"
  mode 0644
  variables(
		"port" => 80,
		"app_name" => "writewithme",
		"socket_path" => www_sock_path,
		"server_ip" => "0.0.0.0",
		"server_port" => 80,
		"server_name" => "writewithme.kle.io",
		"static_path" => public_path
  )
	notifies :reload, resources(:service => "nginx")
end

execute "nxensite #{name}" do
  command "/usr/sbin/nxensite #{name}.conf"
  notifies :restart, resources(:service => "nginx")
  not_if do ::File.symlink?("#{node[:nginx][:dir]}/sites-enabled/#{name}") end
end