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
#   If defined, riak's app.config file will have the param: source => $source.
#   Mutually exclusive with $template.
#
# template:
#   Sets the content of the content parameter for the main configuration file
#
# vm_args_source:
#   Sets the source parameter for the configuration file.
#   Mutually exclusive with vm_args_template.
#
# vm_args_template:
#   File to use for templating vm.args
#
# architecture:
#   What architecture to fetch/run on
#
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
# == Author
#   Henrik Feldt, github.com/haf/puppet-riak.
#
class riak(
  $version = $riak::params::version,
  $package = $riak::params::package,
  $package_hash = '',
  $source = $riak::params::source,
  $template = $riak::params::template,
  $vm_args_source = $riak::params::vm_args_source,
  $vm_args_template = $riak::params::vm_args_template,
  $architecture = $riak::params::architecture,
  $log_dir = $riak::params::log_dir,
  $erl_log_dir = $riak::params::erl_log_dir,
  $service_autorestart = true,
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

  $manage_service_autorestart = $service_autorestart ? {
    true => 'Service[riak]',
    false => undef,
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
    # todo: support source
    content => template($template),
    notify  => $manage_service_autorestart
  }
  
  file { '/etc/riak/vm.args':
    ensure  => present,
    # todo: support source
    content => template($vm_args_template),
    notify  => $manage_service_autorestart
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
