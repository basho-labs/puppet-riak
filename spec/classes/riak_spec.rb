require 'spec_helper'

describe 'riak', type => :class do
  let :facts do
    {}
  end
  describe 'at baseline with defaults' do
    let :params do ; {} ; end
    it { should contain_class('riak') }
    it { should contain_class('riak::package') }
    it { should contain_class('riak::config') }
    it { should contain_class('riak::service') }
  end
end