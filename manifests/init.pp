# Class: riak
#
# This module manages Riak, the dynamo-based NoSQL database.
#
# == Parameters
#
# version:
#   Version of package to fetch.
#
# package:
#   Name of package as known by OS.
#
# package_hash:
#   A URL of a hash-file or sha2-string in hexdigest
#
# install_curl:
#   If true, this module will define a package['curl'] resource which is necessary
#   to support managing repos. If you wish to manage the installation of curl via
#   another module, then you should set this to false.
#
# manage_ulimit:
#   If +true+ it will try to install a template and set the ulimits for the
#   riak user in /etc/security/limits.conf. If you manage this file in another
#   module then you should set this to +false+ and ensure you set appropriate
#   limits for riak as per riak::params::ulimit
#
# manage_repos:
#   If +true+ it will try to setup the repositories provided by basho.com to
#   install Riak. If you manage your own repositories for whatever reason you
#   probably want to set this to +false+.
#
# source:
#   Sets the content of source parameter for main configuration file
#   If defined, riak's app.config file will have the param: source => $source.
#   Mutually exclusive with $template.
#
# template:
#   Sets the content of the content parameter for the main configuration file
#
# vmargs_source:
#   Sets the content of source parameter for vm.args configuration file
#   If defined, riak's vm.args file will have the param: source => $source.
#   Mutually exclusive with $vmargs_template.
#
# vmargs_template:
#   Sets the content of the content parameter for the vm.args configuration file
#
# architecture:
#   What architecture to fetch/run on
#
# ip:
#   What ip address to listen on
#
# == Requires
#
# * stdlib (module)
# * hiera-puppet (module)
# * hiera (package in 2.7.x, but included inside Puppet 3.0)
#
# == Usage
#
# === Default usage:
#   This gives you all the defaults:
#
# class { 'riak': }
#
# === Overriding configuration
#
#   In this example, we're adding HTTPS configuration
#   with a certificate file / public key and a private
#   key, both placed in the /etc/riak folder.
#
#   When you add items to the 'cfg' parameter, they will override the
#   already defined defaults with those keys defined. The hash is not
#   hard-coded, so you don't need to change the manifest when new config
#   options are made available.
#
#   You can probably benefit from using hiera's hierarchical features
#   in this case, by defining defaults in a yaml file for all nodes
#   and only then configuring specifics for each node.
#
#  class { 'riak':
#    cfg => {
#      riak_core => {
#        https => {
#          "__string_${$::ipaddress}" => 8443
#        },
#        ssl => {
#          certfile => "${etc_dir}/cert.pem",
#          keyfile  => "${etc_dir}/key.pem",
#        }
#      }
#    }
#  }
#
# == Author
#   Henrik Feldt, github.com/basho/puppet-riak.
#
class riak (
  $version             = hiera('version', $riak::params::version),
  $package             = hiera('package', $riak::params::package),
  $download            = hiera('download', $riak::params::download),
  $use_repos           = hiera('use_repos', $riak::params::use_repos),
  $install_curl        = hiera('install_curl', true),
  $manage_repos        = hiera('manage_repos', true),
  $manage_ulimit       = hiera('manage_ulimit', true),
  $download_hash       = hiera('download_hash', $riak::params::download_hash),
  $source              = hiera('source', ''),
  $template            = hiera('template', ''),
  $vmargs_source       = hiera('vmargs_source', ''),
  $vmargs_template     = hiera('vmargs_template', ''),
  $architecture        = hiera('architecture', $riak::params::architecture),
  $log_dir             = hiera('log_dir', $riak::params::log_dir),
  $erl_log_dir         = hiera('erl_log_dir', $riak::params::erl_log_dir),
  $etc_dir             = hiera('etc_dir', $riak::params::etc_dir),
  $data_dir            = hiera('data_dir', $riak::params::data_dir),
  $service_autorestart = hiera('service_autorestart', $riak::params::service_autorestart),
  $ip                  = hiera('ip', $::ipaddress),
  $cfg                 = hiera_hash('cfg', {}),
  $vmargs_cfg          = hiera_hash('vmargs_cfg', {}),
  $disable             = false,
  $disableboot         = false,
  $absent              = false,
  $ulimit              = $riak::params::ulimit,
  $limits_template     = $riak::params::limits_template
) inherits riak::params {

  include stdlib

  $pkgfile = "/tmp/${$package}-${$version}.${$riak::params::package_type}"

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
    /[0-9]/: {
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
    /true/  => 'Service[riak]',
    default => undef,
  }

  anchor { 'riak::start': }

  package { $riak::params::deps:
    ensure  => $manage_package,
    require => Anchor['riak::start'],
    before  => Anchor['riak::end'],
  }

  if $use_repos == true {
    package { $package:
      ensure  => $riak_pkg_ensure,
      require => [
        Class[riak::config],
        Package[$riak::params::deps],
        Anchor['riak::start'],
      ],
      before  => Anchor['riak::end'],
    }
  } else {
    httpfile {  $pkgfile:
      ensure  => present,
      source  => $download,
      hash    => $download_hash,
      require => Anchor['riak::start'],
      before  => Anchor['riak::end'],
    }
    package { $package:
      ensure   => $manage_package,
      source   => $pkgfile,
      provider => $riak::params::package_provider,
      require  => [
        Httpfile[$pkgfile],
        Package[$riak::params::deps],
        Anchor['riak::start'],
      ],
      before   => Anchor['riak::end'],
    }
  }

  file { $etc_dir:
    ensure  => directory,
    mode    => '0755',
    require => Anchor['riak::start'],
    before  => Anchor['riak::end'],
  }

  class { 'riak::appconfig':
    absent   => $absent,
    source   => $source,
    template => $template,
    cfg      => $cfg,
    require  => [
      File[$etc_dir],
      Anchor['riak::start'],
    ],
    notify   => $manage_service_autorestart,
    before   => Anchor['riak::end'],
  }

  class { 'riak::config':
    absent       => $absent,
    install_curl => $install_curl,
    manage_repos => $manage_repos_real,
    manage_ulimit => $manage_ulimit,
    require      => Anchor['riak::start'],
    before       => Anchor['riak::end'],
  }

  class { 'riak::vmargs':
    absent  => $absent,
    source   => $vmargs_source,
    template => $vmargs_template,
    cfg     => $vmargs_cfg,
    require => [
      File[$etc_dir],
      Anchor['riak::start'],
    ],
    before  => Anchor['riak::end'],
    notify  => $manage_service_autorestart,
  }

  group { 'riak':
    ensure => present,
    system => true,
    require => Anchor['riak::start'],
    before  => Anchor['riak::end'],
  }

  user { 'riak':
    ensure  => ['present'],
    system => true,
    gid     => 'riak',
    home    => $data_dir,
    require => [
      Group['riak'],
      Anchor['riak::start'],
    ],
    before  => Anchor['riak::end'],
  }

  service { 'riak':
    ensure     => $manage_service_ensure,
    enable     => $manage_service_enable,
    hasrestart => $riak::params::has_restart,
    require    => [
      Class['riak::appconfig'],
      Class['riak::vmargs'],
      Class['riak::config'],
      User['riak'],
      Package[$package],
      Anchor['riak::start'],
    ],
    before  => Anchor['riak::end'],
  }

  anchor { 'riak::end': }
}
