# == Class: riak::cs::vmargs
#   Manages /etc/riak-cs/vm.args
#
class riak::cs::vmargs (
  $cfg         = {},
  $erl_log_dir = hiera('erl_log_dir', $riak::cs::params::erl_log_dir),
  $template    = hiera('vm_args_template', ''),
  $source      = hiera('vm_args_source', ''),
  $absent      = false,
) inherits riak::cs::params {

  $vmargs_cfg = merge({
    '-name'      => "riakcs@${::fqdn}",
    '-setcookie' => 'riak',
    '+K'         => true,
    '+A'         => 64,
    '+W'         => w,

    '-smp'       => 'enable',
    '-env'       => {
      'ERL_MAX_PORTS'  => 4096,
      'ERL_CRASH_DUMP' => "${$erl_log_dir}/erl_crash.dmp",
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

  anchor { 'riak::cs::vmargs::start': }

  file { '/etc/riak-cs/vm.args':
    ensure  => $manage_file,
    content => $manage_template,
    source  => $manage_source,
    require => Anchor['riak::cs::vmargs::start'],
    before  => Anchor['riak::cs::vmargs::end'],
  }

  anchor { 'riak::cs::vmargs::end': }
}
