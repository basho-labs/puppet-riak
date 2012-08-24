require 'spec_helper'

describe 'riak::package', :type => :class do

  let :facts do
    {
      :operatingsystem => 'ubuntu'
    }
  end

  describe 'at baseline defaults' do

    let :params do 
      {
        :type => 'deb',
        :hash => 'abcd',
        :version => '1.2.0',
        :package => 'custom_riak'
      }
    end

    it 'should be downloading latest' do
      subject.should contain_httpfile('/tmp/custom_riak-1.2.0.deb').with({
        :path => '/tmp/custom_riak-1.2.0.deb',
        :hash => 'abcd'
      })
    end

    it {
      should contain_package('custom_riak').with({
        :ensure => 'installed'
      })
    }
    
  end
end