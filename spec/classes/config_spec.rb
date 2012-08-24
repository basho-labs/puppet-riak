require 'spec_helper'

describe 'riak::config', type => :class do
  let :facts do {} ; end
  describe 'at baseline defaults' do
    it 'should have a configuration file at "/etc/riak/app.config"' do
      subject.should contain_file('/etc/riak/app.config').with({
        :ensure => 'present'
      })
    end
  end
end