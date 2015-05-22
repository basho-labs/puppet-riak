# This sets some (basically random) configuration settings to validate that
# the module generates valid config files
class { '::riak':
  package_name        => 'riak',
  service_name        => 'riak',
  manage_package      => true,
  manage_repo         => true,
  version             => 'latest',
  ulimits_nofile_soft => 88536,
  ulimits_nofile_hard => 98536,
  settings            => {
    'log.syslog'                 => 'on',
    'listener.protobuf.internal' => "${::ipaddress}:8087"
  },
}
