# == Class: riak::stanchion::appconfig
#   manages /etc/stanchion/app.config
#
class riak::stanchion::appconfig(
  $cfg = {},
  $source = hiera('source', ''),
  $template = hiera('template', ''),
  $absent = false
) {

  require riak::stanchion::params

  # merge the given $cfg parameter with the default,
  # favoring the givens, rather than the defaults
  $appcfg = merge_hashes({
    stanchion                => {
      stanchion_ip           => $::ipaddress,
      stanchion_port         => 8085,
      auth_bypass                  => '__atom_false',
      riak_ip                      => $::ipaddress,
      riak_pb_port                 => 8087,
      admin_key                    => admin-key,
      admin_secret                 => admin-secret,
    },
    lager => {
      handlers                     => {
        lager_console_backend      => '__atom_info',
        lager_file_backend   => [
          ['__tuple', $riak::stanchion::params::error_log, '__atom_error', 10485760, '$D0', 5],
          ['__tuple', $riak::stanchion::params::info_log,  '__atom_info', 10485760, '$D0', 5],
        ],
      },
      crash_log                    => $riak::stanchion::params::crash_log,
      crash_log_msg_side           => 65536,
      crash_log_size               => 10485760,
      crash_log_date               => '$D0',
      crash_log_count              => 5,
      error_logger_redirect        => true,
    },
    sasl => {
      sasl_error_logger            => false,
    },
  }, $cfg)

  $manage_file = $absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_template = $template ? {
    ''      => write_erl_config($appcfg),
    default => template($template),
  }

  $manage_source = $source ? {
    ''      => undef,
    default => $source,
  }

  anchor { 'riak::stanchion::appconfig::start': }

  file { [
      '/var/log/stanchion',
    ]:
    ensure  => directory,
    mode    => '0644',
    owner   => 'stanchion',
    group   => 'stanchion',
    require => Anchor['riak::stanchion::appconfig::start'],
    before  => Anchor['riak::stanchion::appconfig::end'],
  }

  file { '/etc/stanchion/app.config':
    ensure  => $manage_file,
    content => $manage_template,
    source  => $manage_source,
    require => [
      Anchor['riak::stanchion::appconfig::start'],
    ],
    before  => Anchor['riak::stanchion::appconfig::end'],
  }

  anchor { 'riak::stanchion::appconfig::end': }
}
