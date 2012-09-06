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

desc 'runs \'puppet apply --noop\' on the manifests'
task :noop do
  system 'find tests -name init.pp | xargs -n 1 -t bundle exec puppet apply --noop --modulepath=spec/fixtures/modules'
end

directory 'graphs'

desc "Convert too dotfiles in the graph folder to png files"
task :dot_to_png => 'graphs' do
  Dir.glob('graphs/*.dot') do |dot|
    puts "Converting #{dot} to png"
    which = RUBY_PLATFORM =~ /(win|w)32$/ ? "where dot >NUL 2>&1" : "which dot >/dev/null 2>&1"
    system "dot -Tpng #{dot} -o graphs/#{File.basename(dot, '.*')}.png" if system(which)
  end
end

namespace :vagrant do

  desc 'Bring the VM up'
  task :up => [:spec_prep] do
    system 'vagrant up'
  end

  desc 'Suspend the VM (alias \'suspend\')'
  task :down => [:spec_prep] do
    system 'vagrant suspend'
  end

  task :suspend => :down

  task :_provision do ; system 'vagrant provision' ; end

  desc 'Provision VM when already running'
  task :provision => [:spec_prep, :"vagrant:_provision", :dot_to_png]

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
