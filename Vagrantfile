# -*- mode: ruby -*-
# vi: set ft=ruby :
###  (c) Marcellus Siegburg, 2013, License: GPL

Vagrant::Config.run do |config|
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  config.vm.customize ["modifyvm", :id,
                       "--name", "Autotool Autoconfigured " + Time.now.to_s,
                       "--memory", "768"]

  config.vm.forward_port 80, 8080, :auto => true

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "init.pp"
    puppet.options = ["--user", "vagrant"]
  end

  #config.vm.provision :puppet, :module_path => "manifests/autotool"
end
