# Class: riak::package
#
# Handles the Riak configuration in /etc/riak/*
#
# Parameters: none
#
# Actions: none
#
# Requires: none
#
# Sample Usage: none
class riak::config {
  file { '/etc/riak/app.config':
    ensure => present,
    source => 'puppet:///modules/riak/app.config'
  }
}