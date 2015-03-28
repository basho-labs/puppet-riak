# == Class riak::params
#
# This class is meant to be called from riak.
# It sets variables according to platform.
#
class riak::params {
  $version          = 'present' # setting to latest could result in uplanned upgrades
  $manage_repo      = true
  $manage_package   = true
  $riak_conf        = '/etc/riak/riak.conf'
  $riak_user        = 'riak'
  $riak_group       = 'riak'
  $settings         = {}
  case $::osfamily {
    'Debian': {
      $package_name = 'riak'
      $service_name = 'riak'
    }
    'RedHat', 'Amazon': {
      $package_name = 'riak'
      $service_name = 'riak'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
