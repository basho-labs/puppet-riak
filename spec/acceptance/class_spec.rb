require 'spec_helper_acceptance'
shared_examples_for "a running riak service" do
  describe package('riak') do
    it { is_expected.to be_installed }
  end

  describe service('riak') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe port(8087) do
    it {
      is_expected.to be_listening
    }
  end
end

shared_examples_for "riak self-tests" do
  describe command('riak chkconfig') do
    its(:stdout) { is_expected.to match /config is OK/ }
    its(:stderr) { is_expected.to_not match /[error]/ }
  end

  describe command('riak-admin ringready') do
    its(:stdout) { is_expected.to match /TRUE All nodes agree on the ring/ }
  end

  describe command('riak-admin ring-status') do
    its(:stdout) { is_expected.to match /All nodes are up and reachable/ }
  end

  describe command('riak-admin test') do
    its(:stdout) { is_expected.to match /Successfully completed/ }
    its(:stderr) { is_expected.to_not match /not reachable/ }
    its(:stdout) { is_expected.to_not match /Failed to write test value/ }
  end
end

describe 'riak class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'riak': }

      # wait for riak to finish starting before we run tests
      exec {'/usr/sbin/riak-admin test':
        try_sleep => '.5', # sleep .5 seconds between tries until it passes
        tries     => 60,
        require   => Class['riak'],
        # the unless is to avoid running this when the manifest is applied
        # a second time, which would fail the idempotency check.
        unless    => '/usr/sbin/riak-admin test',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    it_behaves_like "a running riak service"
    it_behaves_like "riak self-tests"
  end

  context 'with config parameters set' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { '::riak':
        package_name   => 'riak',
        service_name   => 'riak',
        manage_package => true,
        manage_repo    => true,
        version        => 'latest',
        settings       => {
          'log.syslog'                              => 'on',
          'erlang.schedulers.force_wakeup_interval' => '500',
          'erlang.schedulers.compaction_of_load'    => false,
          'buckets.default.last_write_wins'         => true,
        },
      }

      # wait for riak to finish starting before we run tests
      exec {'/usr/sbin/riak-admin test':
        try_sleep => '.5', # sleep .5 seconds between tries until it passes
        tries     => 60,
        require   => Class['riak'],
        # the unless is to avoid running this when the manifest is applied
        # a second time, which would fail the idempotency check.
        unless    => '/usr/sbin/riak-admin test',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    it_behaves_like "a running riak service"
    it_behaves_like "riak self-tests"
    describe file('/etc/riak/riak.conf') do
      its(:content) { should match /log\.syslog = on/ } # custom setting
      its(:content) { should match /erlang\.schedulers\.force_wakeup_interval = 500/ } # custom setting
      its(:content) { should match /buckets.default.last_write_wins = true/ } # custom setting
      its(:content) { should match /log.crash.size = 10MB/ } # expected default setting
    end
  end
end
