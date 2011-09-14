if platform?("debian", "ubuntu")
  # Add a script to restore the rules on boot
  template "/etc/network/if-up.d/iptables" do
    source "iptables.erb"
    owner "root"
    group "root"
    mode 0755
  end
end