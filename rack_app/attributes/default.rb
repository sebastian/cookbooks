# Change these for environment
# The [:rack_apps][:apps] array should contain rack apps following the pattern
# {
#   :app_name_short => "NAME",
#   :description => "Describe the purpose of the app",
#   :port => "PORT",
#   :ip => "0.0.0.0",
#   :server_name => "DOMAIN.com" 
# }
default[:rack_app][:apps] = Array.new

# Set the default path for where the rack apps are installed.
# A subfolder will be made per rack app, named after the app_name_short
default[:rack_app][:base_path] = "/webapps/"
