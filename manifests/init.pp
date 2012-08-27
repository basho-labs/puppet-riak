# Class: riak
#
# This module manages Riak, the dynamo-based NoSQL database.
#
# == Parameters
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
  $package_hash = undef,
  $architecture = $riak::params::architecture,
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

  anchor { 'riak::start': }  ->
  
  httpfile {  $pkgfile:
    ensure => present,
    source => $url_source,
    hash   => $actual_hash
  }

  package { $package:
    ensure  => latest,
    require => Httpfile["/tmp/riak-${$version}.${$riak::params::package_type}"],
    provider=> dpkg,
    source  => $pkgfile
  } ->
  
  file { '/etc/riak/app.config':
    ensure => present,
    source => 'puppet:///modules/riak/app.config'
  }  ~>
  
  service { 'riak':
    ensure  => installed,
    require => [ File['/etc/riak/vm.args'], File['/etc/riak/app.config'] ],
    enable  => true
  } ->
  
  anchor { 'riak::end': }
}
