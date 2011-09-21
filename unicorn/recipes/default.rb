include_recipe "ruby::gc_wrapper"

gem_package "unicorn" do
  version node[:unicorn][:version]
end

cookbook_file "/usr/local/bin/unicornctl" do
  mode 0755
end

# Folder for webapps
directory "/webapps" do
  mode 0755
  action :create
  recursive true
	owner "admin"
	group "admin"
end	
