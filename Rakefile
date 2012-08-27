# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'rubygems'
require 'rspec-puppet'
require "bundler"
Bundler.setup(:default)

require 'puppetlabs_spec_helper/rake_tasks'

desc 'like \'rake spec\' but without deleting fixture contents'
task :specs do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_standalone].invoke
end

namespace :vagrant do

  task :ensure_pp do
    vpp = File.join 'tests', 'vagrant-riak.pp'
    mfs = File.join 'spec', 'fixtures', 'manifests'
    cp vpp, mfs
  end

  desc 'Bring the VM up'
  task :up => [:spec_prep] do
    system 'vagrant up'
  end
  
  desc 'Suspend the VM (alias \'suspend\')'
  task :down => [:spec_prep] do
    system 'vagrant suspend'
  end
  
  task :suspend => :down
  
  desc 'Provision VM when already running'
  task :provision => [:spec_prep, :"vagrant:ensure_pp"] do
    system 'vagrant provision'
  end
  
  desc 'Destroy the VM completely'
  task :destroy do
    system 'vagrant destroy'
  end
  
  desc 'Get the status'
  task :status do
    system 'vagrant status'
  end
  
  task :reload => [:spec_prep] do
    system 'vagrant reload'
  end
end
