define :unicorn_instance, :enable => true do

	puts "############## Got conf_path: #{params[:conf_path]}"
	puts "######## Listing parameters:"
	bluepill_params = Hash.new
  params.each { |k, v| puts "#{k}: #{v}"; bluepill_params[k] = v }

  template params[:conf_path] do
    source "unicorn.conf.erb"
    cookbook "unicorn"
    variables params
  end

  bluepill_monitor "bluepill-#{params[:name]}" do
    cookbook 'unicorn'
    source "bluepill.conf.erb"
		puts "######## Bluepill params listing parameters:"
    bluepill_params.each { |k, v| puts "#{k}: #{v}"; send(k.to_sym, v) }
  end

end