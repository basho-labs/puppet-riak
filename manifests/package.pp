class riak::package {
  package { $riak::package:
    ensure => installed
  }
}