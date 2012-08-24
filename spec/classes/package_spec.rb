require 'spec_helper'

describe 'riak::package', :type => :class do

  let :facts do ; {} ; end

  describe 'at baseline defaults' do

    let :params do 
      {
        :type => 'deb',
        :hash => 'abcd',
        :version => '1.2.0'
      }
    end

    it 'should be downloading latest' do
      subject.should contain_httpfile('/tmp/riak-1.2.0.deb').with({
        :path => '/tmp/riak-1.2.0.deb',
        :hash => 'abcd'
      })
    end

    it {
      should contain_package('riak').with({
        :ensure => 'installed'
      })
    }

  end
end