Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"
  config.vm.box_version = "11.20230615.1"

  config.vm.provider :libvirt do |domain|
    domain.memory = 4096
    domain.cpus = 2
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", path: "./server/init.sh"
  # config.vm.provision "shell", path: "./server/vault/configure.sh"

  config.vm.provision "shell", inline: <<-SCRIPT
    set -eu

    cd /vagrant/server

    ./init.sh
    ./vault/configure.sh
    ./nomad/configure.sh
  SCRIPT
end
