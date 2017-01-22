# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.name = "swarm_saltmaster"
  end

  config.vm.define :swarm_saltmaster do |master_config|
    master_config.vm.box = "ubuntu/trusty64"
    master_config.vm.host_name = 'saltmaster.local'
    master_config.vm.network "private_network", ip: "10.0.0.110"
    master_config.vm.network :forwarded_port, host: 80, guest: 80
    master_config.vm.network :forwarded_port, host: 8080, guest: 8080
    master_config.vm.synced_folder "./saltstack/salt/", "/srv/salt"
    master_config.vm.synced_folder "./saltstack/pillar/", "/srv/pillar"
    master_config.vm.synced_folder "utils", "/home/vagrant/utils"
    master_config.vm.synced_folder "saltstack/etc/master.d", "/etc/salt/master.d"

    master_config.vm.provision :salt do |salt|
      salt.master_config = "saltstack/etc/master"
      salt.master_key = "saltstack/keys/master_minion.pem"
      salt.master_pub = "saltstack/keys/master_minion.pub"
      salt.minion_key = "saltstack/keys/master_minion.pem"
      salt.minion_pub = "saltstack/keys/master_minion.pub"
      salt.seed_master = {
                          "managersaltminion1" => "saltstack/keys/minion1.pub",
                          "workersaltminion2" => "saltstack/keys/minion2.pub",
                          "workersaltminion3" => "saltstack/keys/minion3.pub"
                         }

      salt.install_type = "stable"
      salt.install_master = true
      salt.no_minion = true
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-P -c /tmp"
    end

    master_config.vm.provision "shell", inline: <<-SHELL
     sudo apt-get update
     sudo apt-get install -y salt-api
   SHELL

   master_config.vm.provision "file", source: "saltstack/etc/ssl/private/cert.pem", destination: "~/temp/cert.pem"
   master_config.vm.provision "file", source: "saltstack/etc/ssl/private/key.pem", destination: "~/temp/key.pem"
   master_config.vm.provision "shell" do |s|
     s.inline = "cp /home/vagrant/temp/*.pem /etc/ssl/private/"
     s.privileged = true
   end
  end

  config.vm.define :swarm_manager_saltminion1 do |minion_config|
    minion_config.vm.box = "ubuntu/trusty64"
    minion_config.vm.host_name = 'managersaltminion1.local'
    minion_config.vm.network "private_network", ip: "10.0.0.111"
    minion_config.vm.synced_folder "saltstack/etc/minion.d", "/etc/salt/minion.d"

    minion_config.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.name = "swarm_manager_saltminion1"
    end

    minion_config.vm.provision :salt do |salt|
      salt.minion_config = "saltstack/etc/minion1"
      salt.minion_key = "saltstack/keys/minion1.pem"
      salt.minion_pub = "saltstack/keys/minion1.pub"
      salt.install_type = "stable"
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-P -c /tmp"
    end
  end

  config.vm.define :swarm_worker_saltminion2 do |minion_config|
    minion_config.vm.box = "ubuntu/trusty64"
    minion_config.vm.host_name = 'workersaltminion2.local'
    minion_config.vm.network "private_network", ip: "10.0.0.112"

    minion_config.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.name = "swarm_worker_saltminion2"
    end

    minion_config.vm.provision :salt do |salt|
      salt.minion_config = "saltstack/etc/minion2"
      salt.minion_key = "saltstack/keys/minion2.pem"
      salt.minion_pub = "saltstack/keys/minion2.pub"
      salt.install_type = "stable"
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-P -c /tmp"
    end
  end

  config.vm.define :swarm_worker_saltminion3 do |minion_config|
    minion_config.vm.box = "ubuntu/trusty64"
    minion_config.vm.host_name = 'workersaltminion3.local'
    minion_config.vm.network "private_network", ip: "10.0.0.113"

    minion_config.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.name = "swarm_worker_saltminion3"
    end

    minion_config.vm.provision :salt do |salt|
      salt.minion_config = "saltstack/etc/minion3"
      salt.minion_key = "saltstack/keys/minion3.pem"
      salt.minion_pub = "saltstack/keys/minion3.pub"
      salt.install_type = "stable"
      salt.verbose = true
      salt.colorize = true
      salt.run_highstate = false
      salt.bootstrap_options = "-P -c /tmp"
    end
  end

end
