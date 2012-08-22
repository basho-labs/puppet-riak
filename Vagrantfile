# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  # config.vm.forward_port 80, 8080
  # config.vm.share_folder "files-puppet", "/etc/puppet/files", "files"
  config.vm.host_name = 'riak-1'
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "../tests/vagrant-riak.pp"
    #puppet.modules_path = "modules"
    #puppet.options = [ '--debug', '--verbose' ]
  end
end
