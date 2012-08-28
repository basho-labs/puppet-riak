require 'rspec-hiera-puppet'

shared_context "hieradata" do
  let :hiera_config do
    {
      # this specifies that rspec overrides what's been defined in `riak::params`
      :backends => ['rspec', 'puppet'],
      :hierarchy => ['%{location}', '%{environment}', '%{calling_module}'],
      :puppet   => { :datasource => 'params' },
      :rspec    => respond_to?(:hiera_data) ? send(:hiera_data) : {}
    }
  end
end
