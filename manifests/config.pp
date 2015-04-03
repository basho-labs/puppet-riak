# == Class riak::config
#
# This class is called from riak for service config.
# see http://docs.basho.com/riak/latest/ops/advanced/configs/configuration-files/
# for descriptions of these settings
#
class riak::config {
  $merged_settings = merge($::riak::params::settings,$::riak::settings)
  file { $::riak::params::riak_conf:
    owner   => $::riak::params::riak_user,
    group   => $::riak::params::riak_group,
    mode    => '0644',
    content => template('riak/riak.conf.erb'),
    notify  => Service[$::riak::service_name],
    before  => Service[$::riak::service_name],
  }
  # set ulimits max file handles
  riak::tuning::limits {
    "${::riak::params::riak_user}-soft":
      user    => $::riak::params::riak_user,
      type    => soft,
      item    => nofile,
      value   => $::riak::ulimits_nofile_soft;
    "${::riak::params::riak_user}-hard":
      user    => $::riak::params::riak_user,
      type    => hard,
      item    => nofile,
      value   => $::riak::ulimits_nofile_hard;
  }
}
