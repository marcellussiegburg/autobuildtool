# -*- mode: ruby -*-
# vi: set ft=ruby :
###  (c) Marcellus Siegburg, 2013, License: GPL

require 'yaml'
vmconf = YAML::load_file("config/config.yaml")

Vagrant.configure("2") do |config|
  config.vm.box = vmconf['vm']['box']
  config.vm.box_url = vmconf['vm']['box_url']

  config.vm.provider :virtualbox do |v|
    v.name = "Autotool Autoconfigured " + Time.now.to_s
    v.customize ["modifyvm", :id,
                 "--memory", vmconf['vm']['memory']]
  end

  config.vm.network :forwarded_port, id: :ssh, guest: 22, host: vmconf['vm']['ssh_port'], auto_correct: vmconf['vm']['ssh_port_auto_correct']
  config.vm.network :forwarded_port, id: :http, guest: 80, host: vmconf['vm']['web_port'], auto_correct: vmconf['vm']['web_port_auto_correct']

  config.vm.provision :shell do |shell|
    shell.path = "prepare.sh"
    shell.args = vmconf['vm']['swap']
    shell.privileged = true
  end

  config.vm.provision :puppet do |puppet|
    puppet.module_path = "modules"
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "site.pp"
    puppet.hiera_config_path = "hiera.yaml"
    puppet.options = ["--user", "vagrant",
                      "--no-daemonize",
                      "--detailed-exitcodes",
                      "--parser", "future",
                      "--verbose",
                      "--logdest", "console",
                      "--logdest", "/vagrant/build.log"]
  end
end
