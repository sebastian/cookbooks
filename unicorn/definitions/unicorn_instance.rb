define :unicorn_instance, :enable => true do

	bluepill_params = Hash.new
  params.each { |k, v| bluepill_params[k] = v unless k.to_s == "name" }

  template params[:conf_path] do
    source "unicorn.conf.erb"
    cookbook "unicorn"
		owner "writewithme"
		group "writewithme"
    variables params
  end

  bluepill_monitor params[:name] do
    cookbook 'unicorn'
    source "bluepill.conf.erb"
    bluepill_params.each { |k, v| send(k.to_sym, v) }
  end

end