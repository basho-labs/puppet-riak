# == Class: riak::cs::appconfig
#   Manages /etc/riak-cs/app.config
#
class riak::cs::appconfig(
  $cfg = {},
  $source = hiera('source', ''),
  $template = hiera('template', ''),
  $absent = false
) {

  require riak::cs::params

  $appcfg = merge_hashes({
    riak_cs  => {
      cs_ip => $::ipaddress,
      cs_port => 8080,
      riak_ip => $::ipaddress,
      riak_pb_port => 8087,
      stanchion_ip => $::ipaddress,
      stanchion_port => 8085,
      stanchion_ssl => false,
      anonymous_user_creation => false,
      admin_key => admin-key,
      admin_secret => admin-secret,
      cs_root_host => 's3.amazonaws.com',
      connection_pools => {
        request_pool => [ '__tuple', 128, 0 ],
        bucket_list_pool => [ '__tuple', 5, 0 ],
      },
      rewrite_module => '__atom_riak_cs_s3_rewrite',
      auth_module => riak_cs_s3_auth,
      fold_objects_for_list_keys => false,
      n_val_1_get_requests => true,
      cs_version => 10300,
      access_log_flush_factor => 1,
      access_log_flush_size => 1000000,
      access_archive_period => 3600,
      access_archiver_max_backlog => 2,
      stroage_schedule => [],
      storage_archive_period => 86400,
      usage_request_limit => 744,
      leeway_seconds => 86400,
      gc_interval => 900,
      gc_retry_interval => 21600,
      trust_x_forwarded_for => false,
      dtrace_support => false,
    },
    webmachine => {
      server_name => 'Riak CS',
      log_handlers => {
        webmachine_log_handler => ['/var/log/riak-cs'],
        riak_cs_access_log_handler => [],
      },
    },
    lager => {
      handlers => {
        lager_console_backend   => '__atom_info',
        lager_file_backend   => [
          ['__tuple', $riak::cs::params::error_log, '__atom_error', 10485760, '$D0', 5],
          ['__tuple', $riak::cs::params::info_log,  '__atom_info', 10485760, '$D0', 5],
        ],
      },
      crash_log             => $riak::cs::params::crash_log,
      crash_log_msg_side    => 65536,
      crash_log_size        => 10485760,
      crash_log_date        => '$D0',
      crash_log_count       => 5,
      error_logger_redirect => true,
    },
    sasl => {
      sasl_error_logger => false,
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

  anchor { 'riak::cs::appconfig::start': }

  file { [
      '/var/log/riak-cs',
    ]:
    ensure  => directory,
    mode    => '0644',
    owner   => 'riakcs',
    group   => 'riakcs',
    require => Anchor['riak::cs::appconfig::start'],
    before  => Anchor['riak::cs::appconfig::end'],
  }

  file { '/etc/riak-cs/app.config':
    ensure  => $manage_file,
    content => $manage_template,
    source  => $manage_source,
    require => [
      Anchor['riak::cs::appconfig::start'],
    ],
    before  => Anchor['riak::cs::appconfig::end'],
  }

  anchor { 'riak::cs::appconfig::end': }
}
