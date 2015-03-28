# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
# This sets some (basically random) configuration settings to validate that
# the module generates valid config files
class { '::riak':
  package_name                                => 'riak',
  service_name                                => 'riak',
  manage_package                              => true,
  manage_repo                                 => true,
  version                                     => 'latest',
  settings                                    => {
    'log.syslog'                              => 'on',
    'erlang.schedulers.force_wakeup_interval' => '500',
    'erlang.schedulers.compaction_of_load'    => false,
    'buckets.default.last_write_wins'         => true,
  },
}
