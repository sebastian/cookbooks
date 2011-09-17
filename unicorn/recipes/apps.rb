counter = 0

node[:active_applications].each do |name, config|
	puts "################### Looping through active apps. name: #{name}, conf: #{config}"

  app_root = "/u/apps/#{name}"

	puts "################### app_root: #{app_root}"
  defaults = Mash.new({
    :pid_path => "#{app_root}/shared/pids/unicorn.pid",
    :worker_count => node[:unicorn][:worker_count],
    :timeout => node[:unicorn][:timeout],
    :socket_path => "/tmp/unicorn/#{name}.sock",
    :backlog_limit => 1,
    :master_bind_address => '0.0.0.0',
    :master_bind_port => "37#{counter}00",
    :worker_listeners => true,
    :worker_bind_address => '127.0.0.1',
    :worker_bind_base_port => "37#{counter}01",
    :debug => false,
    :binary_path => config[:rack_only] ? "#{node[:ruby][:bin_path]} #{node[:languages][:ruby][:bin_dir]}/unicorn" : "#{node[:ruby][:bin_path]} #{node[:languages][:ruby][:bin_dir]}/unicorn_rails",
    :env => 'production',
    :app_root => app_root,
    :enable => true,
    :config_path => "#{app_root}/current/config/unicorn.conf.rb",
    :use_bundler => false
  })
  
  config = defaults.merge(Mash.new(node[:applications][name]))
  
	#  	# Added to have it set up the app
	# unicorn_instance name do
	# 	conf_path config[:config_path]
	# 	options config
	# end

	puts "################### setting up runit_service: unicorn-#{name}"
  runit_service "unicorn-#{name}" do
    template_name "unicorn"
    cookbook "unicorn"
    options config
  end

	puts "################### doing service things for: unicorn-#{name}"    
  service "unicorn-#{name}" do
    action config[:enable] ? [:enable, :start] : [:disable, :stop]
  end

  counter += 1
end
