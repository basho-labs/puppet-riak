require 'spec_helper'

describe 'riak', type => :class do

  let :facts do 
    { :operatingsystem => 'ubuntu' }
  end
  
  describe 'when using default params' do
    let :params do 
      {}
    end

    it 'should include the riak class' do
      subject.should contain_class('riak')
    end
  end
end
