# Class: riak::params
#
# This class implements the module params pattern
#
# Parameters: none
#
# Actions: none
#
# Requires: none
#
# Sample Usage: none
class riak::params {

  $download_os = $::operatingsystem ? {
    /(centos|redhat)/ => 'rhel/6',
    'ubuntu'          => 'ubuntu/precise',
    'debian'          => 'ubuntu/precise',
    default           => 'ubuntu/precise'
  }

  $package = $::operatingsystem ? {
    /(centos|redhat)/ => 'riak',
    default           => 'riak'
  }

  $architecture = $::operatingsystem ? {
    /(centos|redhat)/ => 'el6.x86_64',
    default           => 'amd64'
  }

  $package_type = $::operatingsystem ? {
    /(centos|redhat)/ => 'rpm',
    default           => 'deb'
  }

  $version = '1.2.0'
}