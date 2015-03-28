# == Class riak::config
#
# This class is called from riak for service config.
# see http://docs.basho.com/riak/latest/ops/advanced/configs/configuration-files/
# for descriptions of these settings
#
class riak::config {
  $default_settings = {
    'anti_entropy'                      => 'active',
    'bitcask.data_root'                 => '$(platform_data_dir)/bitcask',
    'bitcask.io_mode'                   => 'erlang',
    'distributed_cookie'                => 'riak',
    'dtrace'                            => 'off',
    'erlang.async_threads'              => '64',
    'erlang.max_ports'                  => '65536',
    'leveldb.maximum_memory.percent'    => '70',
    'listener.http.internal'            => '127.0.0.1:8098',
    'listener.protobuf.internal'        => '127.0.0.1:8087',
    'log.console'                       => 'file',
    'log.console.file'                  => '$(platform_log_dir)/console.log',
    'log.console.level'                 => 'info',
    'log.crash.file'                    => '$(platform_log_dir)/crash.log',
    'log.crash.maximum_message_size'    => '64KB',
    'log.crash'                         => 'on',
    'log.crash.rotation'                => '$D0',
    'log.crash.rotation.keep'           => '5',
    'log.crash.size'                    => '10MB',
    'log.error.file'                    => '$(platform_log_dir)/error.log',
    'log.syslog'                        => 'off',
    'nodename'                          => "riak@${::fqdn}",
    'object.format'                     => '1',
    'object.siblings.maximum'           => '100',
    'object.siblings.warning_threshold' => '25',
    'object.size.maximum'               => '50MB',
    'object.size.warning_threshold'     => '5MB',
    'platform_bin_dir'                  => '/usr/sbin',
    'platform_data_dir'                 => '/var/lib/riak',
    'platform_etc_dir'                  => '/etc/riak',
    'platform_lib_dir'                  => '/usr/lib64/riak/lib',
    'platform_log_dir'                  => '/var/log/riak',
    'riak_control.auth.mode'            => 'off',
    'riak_control'                      => 'off',
    'search'                            => 'off',
    'search.solr.jmx_port'              => '8985',
    'search.solr.jvm_options'           => '-d64 -Xms1g -Xmx1g -XX:+UseStringCache -XX:+UseCompressedOops',
    'search.solr.port'                  => '8093',
    'search.solr.start_timeout'         => '30s',
    'storage_backend'                   => 'bitcask',
  }

  # there are two layers of merges so that params-specific settings can
  # override default settings, then user-specified settings will override
  # those
  $base_settings = merge($default_settings,$::riak::params::settings)
  $merged_settings = merge($base_settings,$::riak::settings)
  file { $::riak::params::riak_conf:
    owner   => $::riak::params::riak_user,
    group   => $::riak::params::riak_group,
    mode    => '0644',
    content => template('riak/riak.conf.erb'),
    notify  => Service[$::riak::service_name],
    before  => Service[$::riak::service_name],
  }
}
