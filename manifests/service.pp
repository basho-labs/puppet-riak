# == Class riak::service
#
# This class is meant to be called from riak.
# It ensure the service is running.
#
class riak::service {

  service { $::riak::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
