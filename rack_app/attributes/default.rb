# Change these for environment
default[:rack_app][:app_name_short] = "unknown_name"
default[:rack_app][:port] = "80"
default[:rack_app][:ip] = "0.0.0.0"
default[:rack_app][:server_name] = "localhost"

default[:rack_app][:app_path] = "/webapps/#{node[:rack_app][:app_name_short]}"
