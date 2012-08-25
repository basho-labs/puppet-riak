require 'spec_helper'
require 'puppet'

##mp = RSpec.configuration.module_path
##Puppet[:modulepath] = Puppet[:modulepath] + ':' + mp if mp
##libs = Puppet[:modulepath].split(':').collect{ |p| Dir["#{p}/*/lib"].entries }.flatten.join(File::PATH_SEPARATOR)
##puts "libs: "+libs
##Puppet[:libdir] = libs
$:.unshift File.join(File.dirname(__FILE__), '..', 'fixtures/modules/riak/lib')
describe 'riak::package', :type => :class do

  let :facts do
    {
      :operatingsystem => 'ubuntu'
    }
  end

  describe 'at baseline defaults' do

    let :params do 
      {
        :hash => 'abcd',
        :version => '1.2.0',
        :package => 'custom_riak'
      }
    end

    it 'should be downloading latest' do
      #pending "waiting for working lib folder for custom types"
      subject.should contain_httpfile('/tmp/custom_riak-1.2.0.deb').with({
        :path => '/tmp/custom_riak-1.2.0.deb',
        :hash => 'abcd'
      })
    end

    it 'should have the riak package' do 
      #pending "waiting for working lib folder for custom types"
      should contain_package('custom_riak').with({
        :ensure => 'installed'
      })
    end 
    
  end
end
