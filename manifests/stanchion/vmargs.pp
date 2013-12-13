# == Class: riak::stanchion::vmargs
#  Manages /etc/riak::stanchion/vm.args
#
class riak::stanchion::vmargs (
  $cfg         = {},
  $erl_log_dir = hiera('erl_log_dir', $riak::stanchion::params::erl_log_dir),
  $template    = hiera('vm_args_template', ''),
  $source      = hiera('vm_args_source', ''),
  $absent      = false,
) inherits riak::stanchion::params {

  $vmargs_cfg = merge({
    '-name'                 => "stanchion@${::fqdn}",
    '-setcookie'            => 'riak',
    '+K'                    => true,
    '+A'                    => 64,
    '+W'                    => w,

    '-smp'                  => 'enable',
    '-env'                  => {
      'ERL_MAX_PORTS'       => 4096,
      'ERL_CRASH_DUMP'      => "${$erl_log_dir}/erl_crash.dmp",
      'ERL_FULLSWEEP_AFTER' => 0,
    }
  }, $cfg)

  $manage_file = $absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_template = $template ? {
    ''      => write_erl_args($vmargs_cfg),
    default => template($template),
  }

  $manage_source = $source ? {
    ''      => undef,
    default => $source,
  }

  anchor { 'riak::stanchion::vmargs::start': }

  file { '/etc/stanchion/vm.args':
    ensure  => $manage_file,
    content => $manage_template,
    source  => $manage_source,
    require => Anchor['riak::stanchion::vmargs::start'],
    before  => Anchor['riak::stanchion::vmargs::end'],
  }

  anchor { 'riak::stanchion::vmargs::end': }
}
