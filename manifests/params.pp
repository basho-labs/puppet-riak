# == Class riak::params
#
# This class is meant to be called from riak.
# It sets variables according to platform.
#
class riak::params {
  $version             = 'present' # setting to latest could result in uplanned upgrades
  $manage_repo         = true
  $manage_package      = true
  $riak_conf           = '/etc/riak/riak.conf'
  $riak_user           = 'riak'
  $riak_group          = 'riak'
  $ulimits_context     = '/files/etc/security/limits.conf'
  $ulimits_nofile_soft = '65536'
  $ulimits_nofile_hard = '65536'
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

  case $::osfamily {
    'Debian': {
      $package_name               = 'riak'
      $service_name               = 'riak'
      $platform_specific_settings = {}
    }
    'RedHat', 'Amazon': {
      $package_name               = 'riak'
      $service_name               = 'riak'
      $platform_specific_settings = {}
    }
    # FreeBSD is included as an example of platform-specific config settings
    # there's no actual test coverage for FreeBSD (yet)
    'FreeBSD': {
      $package_name               = 'riak'
      $service_name               = 'riak'
      $platform_specific_settings = {
        'platform_etc_dir' => '/usr/local/etc/riak',
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
  $settings = merge($default_settings,$platform_specific_settings)

}
