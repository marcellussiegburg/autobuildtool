# -*- mode: ruby -*-
# vi: set ft=ruby :
###  (c) Marcellus Siegburg, 2013, License: GPL

Vagrant::Config.run do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.customize ["modifyvm", :id,
                       "--name", "Autotool Autoconfigured " + Time.now.to_s,
                       "--memory", "2200"]

  config.vm.forward_port 80, 8080, :auto => true

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "init.pp"
    puppet.options = ["--user", "vagrant",
                      "--no-daemonize",
                      "--detailed-exitcodes",
                      "--verbose",
                      "--logdest", "console",
                      "--logdest", "/vagrant/build.log"]
  end
end
