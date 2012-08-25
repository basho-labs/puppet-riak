# Class: riak
#
# This module manages puppet-riak
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
# class { 'riak': }
#
class riak(
  $package = $riak::params::package,
  $disable = false,
  $disableboot = false,
  $absent = false
) inherits riak::params {
  include stdlib
  anchor { 'riak::start': }  ->
  class { 'riak::package': } ~>
  class { 'riak::config': }  ~>
  class { 'riak::service': } ~>
  anchor { 'riak::end': }
}
