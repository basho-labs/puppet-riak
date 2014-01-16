# == Class: riak::stanchion
#
# This module manages riak::stanchion
#
class riak::stanchion (
  $version             = hiera('version', $riak::stanchion::params::version),
  $package             = hiera('package', $riak::stanchion::params::package),
  $download            = hiera('download', $riak::stanchion::params::download),
  $use_repos           = hiera('use_repos', $riak::stanchion::params::use_repos),
  $manage_repos        = hiera('manage_repos', true),
  $download_hash       = hiera('download_hash', $riak::stanchion::params::download_hash),
  $source              = hiera('source', ''),
  $template            = hiera('template', ''),
  $architecture        = hiera('architecture', $riak::stanchion::params::architecture),
  $log_dir             = hiera('log_dir', $riak::stanchion::params::log_dir),
  $erl_log_dir         = hiera('erl_log_dir', $riak::stanchion::params::erl_log_dir),
  $etc_dir             = hiera('etc_dir', $riak::stanchion::params::etc_dir),
  $data_dir            = hiera('data_dir', $riak::stanchion::params::data_dir),
  $service_autorestart = hiera('service_autorestart', $riak::stanchion::params::service_autorestart),
  $cfg                 = hiera_hash('cfg', {}),
  $vmargs_cfg          = hiera_hash('vmargs_cfg', {}),
  $disable             = false,
  $disableboot         = false,
  $absent              = false,
  $ulimit              = $riak::stanchion::params::ulimit,
  $ulimit_etc_default  = false,
) inherits riak::stanchion::params {

  include stdlib

  $pkgfile = "/tmp/${$package}-${$version}.${$riak::stanchion::params::package_type}"

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
    true      => 'stopped',
    default   => $absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  $manage_service_enable = $disableboot ? {
    true        => false,
    default     => $disable ? {
      true      => false,
      default   => $absent ? {
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
    /true/  => 'Service[stanchion]',
    default => undef,
  }

  anchor { 'riak::stanchion::start': }

  package { $riak::stanchion::params::deps:
    ensure  => $riak_pkg_ensure,
    require => Anchor['riak::stanchion::start'],
    before  => Anchor['riak::stanchion::end'],
  }

  if $use_repos == true {
    package { $package:
      ensure  => $manage_package,
      require => [
        Class[riak::stanchion::appconfig],
        Package[$riak::stanchion::params::deps],
        Anchor['riak::stanchion::start'],
      ],
      before  => Anchor['riak::stanchion::end'],
    }
  } else {
    httpfile {  $pkgfile:
      ensure  => present,
      source  => $download,
      hash    => $download_hash,
      require => Anchor['riak::stanchion::start'],
      before  => Anchor['riak::stanchion::end'],
    }
    package { $package:
      ensure   => $manage_package,
      source   => $pkgfile,
      provider => $riak::stanchion::params::package_provider,
      require  => [
        Httpfile[$pkgfile],
        Package[$riak::stanchion::params::deps],
        Anchor['riak::stanchion::start'],
      ],
      before   => Anchor['riak::stanchion::end'],
    }
  }

  file { $etc_dir:
    ensure  => directory,
    mode    => '0755',
    require => Anchor['riak::stanchion::start'],
    before  => Anchor['riak::stanchion::end'],
  }

  class { 'riak::stanchion::appconfig':
    absent   => $absent,
    source   => $source,
    template => $template,
    cfg      => $cfg,
    require  => [
      File[$etc_dir],
      Anchor['riak::stanchion::start'],
    ],
    notify   => $manage_service_autorestart,
    before   => Anchor['riak::stanchion::end'],
  }

  class { 'riak::stanchion::vmargs':
    absent  => $absent,
    cfg     => $vmargs_cfg,
    require => [
      File[$etc_dir],
      Anchor['riak::stanchion::start'],
    ],
    before  => Anchor['riak::stanchion::end'],
    notify  => $manage_service_autorestart,
  }

  group { 'stanchion':
    ensure  => present,
    system  => true,
    require => Anchor['riak::stanchion::start'],
    before  => Anchor['riak::stanchion::end'],
  }

  user { 'stanchion':
    ensure  => ['present'],
    system  => true,
    gid     => 'stanchion',
    home    => $data_dir,
    require => [
      Group['stanchion'],
      Anchor['riak::stanchion::start'],
    ],
    before  => Anchor['riak::stanchion::end'],
  }

  if $ulimit_etc_default == true {
    file { '/etc/default/stanchion':
      ensure  => present,
      mode    => '0644',
      path    => '/etc/default/stanchion',
      content => "ulimit -n ${ulimit}",
    }
  }

  service { 'stanchion':
    ensure     => $manage_service_ensure,
    enable     => $manage_service_enable,
    hasrestart => $riak::stanchion::params::has_restart,
    require    => [
      # Class['riak::stanchion::appconfig'],
      # Class['riak::stanchion::vmargs'],
      User['stanchion'],
      Package[$package],
      Anchor['riak::stanchion::start'],
    ],
    before     => Anchor['riak::stanchion::end'],
  }

  anchor { 'riak::stanchion::end': }
}
