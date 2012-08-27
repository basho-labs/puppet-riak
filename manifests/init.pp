# Class: riak
#
# This module manages Riak, the dynamo-based NoSQL database.
#
# == Parameters
# 
# version:
#   Version of package to fetch
#
# package:
#   Name of package as known by OS
#
# package_hash:
#   A URL of a hash-file or sha2-string in hexdigest
#
# source:
#   Sets the content of source parameter for main configuration file 
#   If defined, riak's app.config file will have the param: source => $source
#
# architecture:
#   What architecture to fetch/run on
#
# vm_args_template:
#   File to use for templating vm.args
#
# == Actions
#
# == Requires
#
# * stdlib (module)
#
# == Usage
#
# class { 'riak': }
#
class riak(
  $version = $riak::params::version,
  $package = $riak::params::package,
  $package_hash = '',
  $source = $riak::params::source,
  $architecture = $riak::params::architecture,
  $vm_args_template = $riak::params::vm_args_template,
  $log_dir = $riak::params::log_dir,
  $erl_log_dir = $riak::params::erl_log_dir,
  $disable = false,
  $disableboot = false,
  $absent = false
) inherits riak::params {

  include stdlib

  $download_os = $::operatingsystem ? {
    /(centos|redhat)/ => 'rhel/6',
    'ubuntu'          => 'ubuntu/precise',
    'debian'          => 'ubuntu/precise',
    default           => 'ubuntu/precise'
  }

  $download_base = "http://downloads.basho.com.s3-website-us-east-1.amazonaws\
.com/riak/CURRENT/${download_os}"

  $url_source = "${$download_base}/riak_${$version}-1_\
${$riak::params::architecture}.${$riak::params::package_type}"

  $url_source_hash = "${$url_source}.sha"

  $actual_hash = $package_hash ? {
    undef   => $url_source_hash,
    ''      => $url_source_hash,
    default => $package_hash
  }

  $pkgfile = "/tmp/${$package}-${$version}.${$riak::params::package_type}"

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  anchor { 'riak::start': }  ->
  
  httpfile {  $pkgfile:
    ensure => present,
    source => $url_source,
    hash   => $actual_hash
  }

  package { 'riak':
    ensure  => latest,
    provider=> dpkg,
    source  => $pkgfile,
    require => Httpfile[$pkgfile],
  }
  
  file { '/etc/riak/app.config':
    ensure  => present,
    source  => 'puppet:///modules/riak/app.config',
    notify  => Service['riak']
  }
  
  file { '/etc/riak/vm.args':
    ensure  => present,
    content  => template($vm_args_template),
    notify  => Service['riak']
  }
  
  service { 'riak':
    ensure  => running,
    enable  => true,
    require => [ 
      File['/etc/riak/vm.args'],
      File['/etc/riak/app.config'],
      Package['riak']
    ],
  } ~>
  
  anchor { 'riak::end': }
}
