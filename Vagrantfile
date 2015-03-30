# -*- mode: ruby -*-
# vi: set ft=ruby :

# This vagrant environment provides a clean slate to develop or test the riak
# module in. It does not currently configure very much of that environment.
#
# this requires two additional vagrant plugins:
# https://github.com/adrienthebo/vagrant-auto_network and
# https://github.com/adrienthebo/vagrant-hosts
# install with:
# vagrant plugin install vagrant-auto_network vagrant-hosts
#
# In addition, you should probably also use:
# - vagrant-cachier will cache package downloads
# - vagrant-vbguest will reinstall virtualbox guest additions as necessary
# To install those, run:
# vagrant plugin install vagrant-vbguest vagrant-cachier
require 'json'

Vagrant.configure("2") do |config|

  # Using vagrant-cachier improves performance if you run repeated yum/apt updates
  if defined? VagrantPlugins::Cachier
    config.cache.auto_detect = true
  end

  # choices for virtual machines:
  config.vm.synced_folder ".", "/etc/puppet/modules/riak"

  # give all nodes a little bit more memory and CPU cores:
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024", "--cpus", "2", "--ioapic", "on"]
  end

#  config.vm.provision "shell",
#    inline: "puppet module install puppetlabs-apt"

  # generate list of puppet modules to be installed from metadata.json
  metadata_json_file = "#{File.dirname(__FILE__)}/metadata.json"
  if File.exist?(metadata_json_file)
    JSON.parse(File.read(metadata_json_file))['dependencies'].each {|key,value|
      module_name = key['name'].to_s
      config.vm.provision "shell",
          inline: "puppet module install #{module_name}"
    }
  else
    puts "metadata.json not found; skipping install of dependencies"
  end
  # specify all Riak VMs:
  nodes = 3
  domain = 'example.com'
  ['puppetlabs/centos-7.0-64-puppet','puppetlabs/ubuntu-14.04-64-puppet','puppetlabs/centos-6.6-64-puppet','puppetlabs/ubuntu-12.04-64-puppet','puppetlabs/debian-7.8-64-puppet'].each do |box|
    platform = box.gsub('/','-')
    (1..nodes).each do |n|
      config.vm.define "#{platform}-#{n}" do |node|
        node.vm.box = box
        node.vm.hostname = "#{platform.gsub('.','-')}-#{n}.example.com"
        node.vm.network :private_network, :auto_network => true
        node.vm.provision :hosts
      end
    end
  end

end
