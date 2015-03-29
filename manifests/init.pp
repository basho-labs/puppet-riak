# == Class: riak
#
# Full description of class riak here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class riak (
  String[1] $package_name = $::riak::params::package_name,
  String[1] $service_name = $::riak::params::service_name,
  Boolean $manage_package = $::riak::params::manage_package,
  Boolean $manage_repo    = $::riak::params::manage_repo,
  String[1] $version      = $::riak::params::version,
  Hash[String, Variant[String, Boolean, Integer]] $settings = {},
) inherits ::riak::params {
  if $manage_repo and $manage_package {
    include ::riak::repository
  }
  if $manage_package {
    include ::riak::install
    Package[$::riak::package_name] ~> File[$::riak::params::riak_conf]
  }
  class { '::riak::config': } ~>
  class { '::riak::service': } ->
  Class['::riak']
}
