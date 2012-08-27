# == Class: riak::params
#
# This class implements the module params pattern
#
# == Usage
#  
# Don't use this class directly; it's inherited where it is needed
#
class riak::params {

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