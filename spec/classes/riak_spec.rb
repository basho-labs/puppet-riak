require 'spec_helper'

describe 'riak', :type => :class do

  let(:title) { "riak" }
  let :facts do ; {} ; end
  
  describe 'at baseline with defaults' do
    let :params do ; {} ; end
    
    it('should contain a top-level class') { 
      should contain_class('riak') 
    }
    
    it { should contain_httpfile('/tmp/riak-1.2.0.deb').with_ensure('present') }
    it { should contain_package('riak').with_ensure('latest') }
    
    
    it { 
      should contain_service('riak').with({
        :ensure => 'installed',
        :enable => 'true' 
      }) 
    }
    
    it { should contain_file('/etc/riak/app.config').with_ensure('present') }
    
    it { should contain_service('riak') }
  
  end
  
  describe 'package configuration' do

    let :params do 
      {
        :version => '1.2.0',
        :package => 'custom_riak',
        :package_hash => 'abcd'
      }
    end

    it 'should be downloading latest' do
      subject.should contain_httpfile('/tmp/custom_riak-1.2.0.deb').with({
        :path => '/tmp/custom_riak-1.2.0.deb',
        :hash => 'abcd'
      })
    end

    it { should contain_package('custom_riak').with_ensure('latest') }
    it { should contain_package('custom_riak').with_source('/tmp/custom_riak-1.2.0.deb') }
    
  end
  
  describe 'when changing configuration' do
    before(:all) { puts catalogue.resources }
    it { catalogue.
          resource('file', '/etc/riak/app.config').
          send(:parameters)[:notify].
          should eq('Service[riak]') }
  end
  
end