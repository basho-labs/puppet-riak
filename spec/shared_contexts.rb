require 'rspec-hiera-puppet'

shared_context "hieradata" do

  let :hiera_config do
    {
      # this specifies that rspec overrides what's been defined in `riak::params`
      :backends => ['rspec', 'puppet'],
      :hierarchy => ['default'],
      :puppet   => { :datasource => 'params' },
      :rspec    => respond_to?(:hiera_data) ? hiera_data : {}
    }
  end

  let(:facts) {{ :ipaddress => '10.42.0.5'}}

end
