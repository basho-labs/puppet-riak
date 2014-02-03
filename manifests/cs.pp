# == Class: riak::cs
#
# This module manages Riak CS
# Based heavily off Riak class
#
class riak::cs (
  $version             = hiera('version', $riak::cs::params::version),
  $package             = hiera('package', $riak::cs::params::package),
  $download            = hiera('download', $riak::cs::params::download),
  $use_repos           = hiera('use_repos', $riak::cs::params::use_repos),
  $manage_repos        = hiera('manage_repos', true),
  $download_hash       = hiera('download_hash', $riak::cs::params::download_hash),
  $source              = hiera('source', ''),
  $template            = hiera('template', ''),
  $architecture        = hiera('architecture', $riak::cs::params::architecture),
  $log_dir             = hiera('log_dir', $riak::cs::params::log_dir),
  $erl_log_dir         = hiera('erl_log_dir', $riak::cs::params::erl_log_dir),
  $etc_dir             = hiera('etc_dir', $riak::cs::params::etc_dir),
  $data_dir            = hiera('data_dir', $riak::cs::params::data_dir),
  $service_autorestart = hiera('service_autorestart',
    $riak::cs::params::service_autorestart),
  $cfg                 = hiera_hash('cfg', {}),
  $riak_cfg            = hiera_hash('riak_cfg', {}),
  $riak_version        = hiera_hash('riak_version', ''),
  $vmargs_cfg          = hiera_hash('vmargs_cfg', {}),
  $disable             = false,
  $disableboot         = false,
  $absent              = false,
  $ulimit              = $riak::cs::params::ulimit,
  $ulimit_etc_default  = false,
) inherits riak::cs::params {
 
  include stdlib
  include riak::repo

  $pkgfile = "/tmp/${$package}-${$version}.${$riak::cs::params::package_type}"

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  $manage_package = $absent ? {
    true    => 'absent',
    default => 'installed',
  }

  # if $version is supplied then manage version of riak when installed via
  # repository (unless we're uninstalling it)
  case $version {
    /[0-9\.]/: {
      $riak_pkg_ensure = $manage_package ? {
        'installed' => $version,
        default     => $manage_package,
      }
    }
    default: { $riak_pkg_ensure = $manage_package }
  }

  $manage_repos_real = $use_repos ? {
    true    => $manage_repos,
    default => false
  }

  $manage_service_ensure = $disable ? {
    true    => 'stopped',
    default => $absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  $manage_service_enable = $disableboot ? {
    true    => false,
    default => $disable ? {
      true    => false,
      default => $absent ? {
        true    => false,
        default => true,
      },
    },
  }

  $manage_file = $absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_service_autorestart = $service_autorestart ? {
    /true/  => 'Service[riak-cs]',
    default => undef,
  }

  anchor { 'riak::cs::start': }

  package { $riak::cs::params::deps:
    ensure  => $manage_package,
    require => Anchor['riak::cs::start'],
    before  => Anchor['riak::cs::end'],
  }

  if $use_repos == true {
    package { $package:
      ensure  => $riak_pkg_ensure,
      require => [
        Class[riak::repo],
        File[$etc_dir],
        Package[$riak::cs::params::deps],
        Anchor['riak::cs::start'],
      ],
      before  => Anchor['riak::cs::end'],
    }
  } else {
    httpfile {  $pkgfile:
      ensure  => present,
      source  => $download,
      hash    => $download_hash,
      require => Anchor['riak::cs::start'],
      before  => Anchor['riak::cs::end'],
    }
    package { $package:
      ensure   => $manage_package,
      source   => $pkgfile,
      provider => $riak::cs::params::package_provider,
      require  => [
        Httpfile[$pkgfile],
        Package[$riak::cs::params::deps],
        Anchor['riak::cs::start'],
      ],
      before   => Anchor['riak::cs::end'],
    }
  }

  file { $etc_dir:
    ensure  => directory,
    mode    => '0755',
  }
  # fix deb pkg bug
  file { "$etc_dir/tokenfile":
    ensure  => file,
    mode    => '0755',
  }

  file { '/usr/sbin/riak-cs-tool':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/riak/riak-cs-tool',
    require => [
      Package[$package],
    ],
  }

  class { 'riak::cs::appconfig':
    absent   => $absent,
    source   => $source,
    template => $template,
    cfg      => $cfg,
    require  => [
      File[$etc_dir],
      Anchor['riak::cs::start'],
    ],
    notify   => $manage_service_autorestart,
    before   => Anchor['riak::cs::end'],
  }

  class { 'riak::cs::vmargs':
    absent  => $absent,
    cfg     => $vmargs_cfg,
    require => [
      File[$etc_dir],
      Anchor['riak::cs::start'],
    ],
    before  => Anchor['riak::cs::end'],
    notify  => $manage_service_autorestart,
  }

  group { 'riakcs':
    ensure  => present,
    system  => true,
    require => Anchor['riak::cs::start'],
    before  => Anchor['riak::cs::end'],
  }

  user { 'riakcs':
    ensure  => ['present'],
    system  => true,
    gid     => 'riakcs',
    home    => $data_dir,
    require => [
      Group['riakcs'],
      Anchor['riak::cs::start'],
    ],
    before  => Anchor['riak::cs::end'],
  }

  if $ulimit_etc_default == true {
    file { '/etc/default/riak-cs':
      ensure  => present,
      mode    => '0644',
      path    => '/etc/default/riak-cs',
      content => "ulimit -n ${ulimit}",
    }
  }
  exec {"wait for riak":
     require =>  Service["riak"],
     command => "/usr/bin/uptime"
  }
  service { 'riak-cs':
    ensure     => running,
    enable     => true,
    hasrestart => $riak::cs::params::has_restart,
    require    => [
      Exec["wait for riak"],
      Class['riak::cs::appconfig'],
      Class['riak::cs::vmargs'],
      User['riakcs'],
      Package[$package],
      Anchor['riak::cs::start'],
    ],
    before     => Anchor['riak::cs::end'],
  }

  anchor { 'riak::cs::end': }
}
