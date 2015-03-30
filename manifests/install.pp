# == Class riak::install
#
# This class is called from riak for install.
#
class riak::install {
  ensure_packages(['sudo'])
  package { $::riak::package_name:
    ensure => $::riak::version,
    before => Service[$::riak::service_name],
  }
}
