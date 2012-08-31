# source:
#   Sets the source parameter for the configuration file.
#   Mutually exclusive with vm_args_template.
#
# template:
#   File to use for templating vm.args
class riak::vmargs(
  $nodename = hiera('nodename', 'riak'),
  $cookie = hiera('cookie', 'riak'),
  $ip = hiera('ipaddress'),
  $K = hiera('K', 'true'),
  $A = hiera('A', '64'),
  $smp = hiera('smp', 'enable'),
  $erl_log_dir = hiera('erl_log_dir'),
  $env_max_ports = hiera('env_max_ports', '4096'),
  $env_crash_dump = hiera('env_crash_dump', undef),
  $source = hiera('source', ''),
  $template = hiera('template', ''),
  $absent = hiera('absent', 'false')
) {

  $manage_file = $absent ? {
    true    => 'absent',
    default => 'present'
  }

  $manage_env_crash_dump = $env_crash_dump ? {
    undef   => "${$erl_log_dir}/erl_crash.dmp",
    default => $env_crash_dump
  }

  $manage_source = $source ? {
    ''      => $source,
    default => $source
  }

  $manage_template = $template ? {
    ''      => undef,
    default => template($template)
  }

  anchor { 'riak::vmargs::start': } ->

  file { '/etc/riak/vm.args':
    ensure  => $manage_file,
    content => $manage_template,
    source  => $source
  } ~>

  anchor { 'riak::vmargs::end': }
}