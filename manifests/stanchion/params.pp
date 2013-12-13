# == Class: riak::stanchion::params
#
class riak::stanchion::params {

  $package = $::operatingsystem ? {
    default => 'stanchion',
  }

  $deps = $::operatingssytem ? {
    /(?i:centos|redhat|Amazon)/ => [],
    default                     => [],
  }

  $package_type = $::operatingsystem ? {
    /(?i:centos|redhat|Amazon)/ => 'rpm',
    default                     => 'deb',
  }

  $package_provider = $::operatingsystem ? {
    /(?i:centos|redhat|Amazon)/ => 'rpm',
    default                     => 'dpkg',
  }

  $architecture = $::operatingsystem ? {
    /(?i:centos|redhat|Amazon)/ => 'x86_64',
    default                     => 'amd64',
  }

  $has_restart = $::operatingsystem ? {
    /(?i:centos|redhat|Amazon)/ => true,
    default                     => false,
  }

  $version = '1.4.3-1'
  $version_maj_min = semver_maj_min($version)
  $use_repos = true
  $get = $::operatingsystem ? {
    /(?i:centos|redhat|Amazon)/ => "/stanchion/${version_maj_min}/${version}/rhel/6/riak::stanchion-${version}-1.el6.${architecture}.${package_type}",
    default                     => "/stanchion/${version_maj_min}/${version}/ubuntu/precise/riak::stanchion_${version}-1_${architecture}.${package_type}",
  }

  $download = "http://downloads.basho.com.s3-website-us-east-1.amazonaws.com${get}"

  $download_hash = "${download}.sha"

  $log_dir = '/var/log/stanchion'
  $error_log = "${log_dir}/error.log"
  $info_log = "${log_dir}/console.log"
  $crash_log = "${log_dir}/crash.log"

  $erl_log_dir = '/var/log/stanchion'
  $data_dir = '/var/lib/stanchion'
  $lib_dir = '/usr/lib/stanchion'
  $bin_dir = '/usr/sbin'
  $etc_dir = '/etc/stanchion'

  $service_autorestart = true

  $ulimit = 65536

}
