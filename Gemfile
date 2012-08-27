# this Gemfile is for the development of the module, you don't need all of these to RUN the module with puppet
source 'https://rubygems.org'
gem 'mocha'
gem 'puppet'
gem 'puppet-lint'
gem 'rspec'
gem 'rspec-puppet'
gem 'puppetlabs_spec_helper'

group :testing do
  gem 'guard' # for running specs easily
  gem 'libnotify' #requires: 'sudo apt-get install libnotify-bin'
  gem 'guard-rake' # for running 'rake vagrant:provision' when editing
  gem 'guard-rspec' # for running specs automatically 
end
#if Windows
#gem 'win32console'
#endif

group :integration do
  gem 'vagrant'
  gem 'vagrant-vbguest'
end
