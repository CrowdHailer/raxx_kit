Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.define "development" do |dev|
    dev.vm.synced_folder ".", "/vagrant"
    dev.vm.hostname = "baobab"

    dev.vm.network "private_network", type: "dhcp"

    dev.vm.network "forwarded_port", guest: 8080, host: 8080
    dev.vm.provision "shell", path: "./provision.sh"
  end

  config.vm.define "dmz" do |dmz|
    dmz.vm.hostname = "dmz"

    dmz.vm.network "private_network", type: "dhcp"
  end

  config.vm.provider "virtualbox" do |v|
    # Running Dialyzer takes up a lot of memory and does not give useful errors if it runs out of memory.
    # http://stackoverflow.com/questions/39854839/dialyxir-mix-task-to-create-plt-exits-without-error-or-creating-table?noredirect=1#comment66998902_39854839
    v.memory = 8192
    v.cpus = 2
  end

  config.ssh.forward_x11 = true
end
