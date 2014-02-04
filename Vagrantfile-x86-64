# -*- mode: ruby -*-
# vi: set ft=ruby :
###  (c) Marcellus Siegburg, 2013, License: GPL

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.provider "virtualbox" do |v|
    v.name = "Autotool Autoconfigured " + Time.now.to_s
    v.customize ["modifyvm", :id,
                 "--memory", "2300"]
  end

  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true

  config.vm.provision "puppet" do |puppet|
    puppet.module_path = "modules"
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "site.pp"
    puppet.options = ["--user", "vagrant",
                      "--no-daemonize",
                      "--detailed-exitcodes",
                      "--verbose",
                      "--logdest", "console",
                      "--logdest", "/vagrant/build.log"]
  end
end
