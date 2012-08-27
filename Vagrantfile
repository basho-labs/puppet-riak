# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'

Vagrant::Config.run do |config|
  config.vm.box = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
  
  # config.vm.forward_port 80, 8080
  # config.vm.share_folder 'files-puppet', '/etc/puppet/files', 'files'
  
  config.vm.share_folder 'riak-module', "#{FileUtils.pwd}", "."
  
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = File.join 'spec', 'fixtures', 'manifests'
    puppet.module_path = File.join 'spec', 'fixtures', 'modules'
    puppet.manifest_file = 'vagrant-riak.pp'
    puppet.options = [ '--trace', '--debug', '--verbose' ]
  end

  # VBox is at .1, number ip.{5,6,7}
  #%w[riak-5 riak-6 riak-7].each {|r|
  %w[riak-5].each {|r|
    config.vm.define :"#{r}" do |cfg|
      cfg.vm.host_name = r
      cfg.vm.network :hostonly, "10.42.0.#{r.slice(4,1)}"
    end
  }
end
